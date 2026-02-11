require 'raylib/dsl'
require 'raylib/raymath'
require 'pry'

#
# Leaf venation visualization
# 
# First version - the goal is to just implement the algorithm
# in simplest form - it will be then base to further refactorings ;-)
#

class Vein
  attr_reader :position, :radius, :inner_radius, :color, :inner_color

  def initialize(position)
    @position = position
    @radius = 10
    @inner_radius = 5
    @color = BLUE
    @inner_color = BLACK
  end
end

class Auxin
  attr_reader :position, :radius, :color

  def initialize(position)
    @position = position
    @radius = 8
    @color = RED
  end
end

PHASE = [
  {key: :init, desc: 'Initial state'},
  {key: :pull, desc: 'Discover veins affected'}
]
PHASES = PHASE.cycle
AUXIN_CREATION_RATE = 3

phase = PHASES.next

def show_info(phase, top)
  draw_text("#{PHASE.index(phase) + 1}. [#{phase[:key].to_s}] - #{phase[:desc]}.", 20, top, 21, LIGHTGRAY)
end

def show_veins
  @veins.each do |v|
    draw_circle(v.position.x, v.position.y, v.radius, v.color)
    draw_circle(v.position.x, v.position.y, v.inner_radius, v.inner_color)
  end
end

def add_auxins(w, h)
  (1..AUXIN_CREATION_RATE).each do
    position = Raylib::Vector2.create(rand(w), rand(h))

    auxin = Auxin.new(position)
    @auxins.push(auxin)
  end
end

def show_auxins
  @auxins.each do |v|
    draw_circle(v.position.x, v.position.y, v.radius, v.color)
  end
end

@veins = []
@auxins = []

init_window(1200, 900, 'Leaf venation patterns demo')
w = get_screen_width
h = get_screen_height

position = Raylib::Vector2.create(w/2, h/4*3)

vein = Vein.new(position)
@veins.push(vein)

add_auxins(w, h)

until window_should_close
  if is_key_pressed(KEY_SPACE)
    phase = PHASES.next
  end

  begin_drawing
  clear_background(get_color(0x181818FF))
  show_veins
  show_auxins
  case phase[:key]
  when :pull
    @auxins.each do |auxin|
      closest_vein = @veins.first
      @veins.each do |vein|
        if vector2_distance(vein.position, auxin.position) < vector2_distance(closest_vein.position, auxin.position)
          closest_vein = vein
        end
        draw_line_v(closest_vein.position, auxin.position, WHITE)
      end
    end
  end
  show_info(phase, h - 30)
  end_drawing
end

close_window