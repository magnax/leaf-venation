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
  attr_reader :position, :radius, :inner_radius, :color, :inner_color,
              :influence_vectors

  def initialize(position)
    @position = position
    @radius = 10
    @inner_radius = 5
    @color = BLUE
    @inner_color = BLACK
    @influence_vectors = []
  end

  def reset_influence
    @influence_vectors = []
  end

  def add_influence(vector)
    @influence_vectors.push(vector)
  end
end

class Auxin
  attr_reader :position, :radius, :color
  attr_accessor :closest_vein

  def initialize(position)
    @position = position
    @radius = 8
    @color = RED
    @closest_vein = nil
  end
end

PHASE = [
  {key: :init, desc: 'Initial state'},
  {key: :pull, desc: 'Discover veins affected'},
  {key: :pull_normalized, desc: 'Normalize vectors to auxin\'s closest vein'},
  {key: :add, desc: 'Add all vectors to auxin\'s closest vein'}
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

def recalculate_and_draw_closest_veins
  @auxins.each do |auxin|
    auxin.closest_vein = @veins.first
    @veins.each do |vein|
      if vector2_distance(vein.position, auxin.position) < vector2_distance(auxin.closest_vein.position, auxin.position)
        auxin.closest_vein = vein
      end
      draw_line_v(auxin.closest_vein.position, auxin.position, WHITE)
    end
  end
end

def show_normalized_closest_veins_vectors
  @veins.each do |vein|
    vein.reset_influence
  end
  @auxins.each_with_index do |auxin, i|
    vs = vector2_subtract(auxin.position, auxin.closest_vein.position)
    vsn = vector2_scale(vector2_normalize(vs), 50)
    a1 = vector2_add(vsn, auxin.closest_vein.position)
    auxin.closest_vein.add_influence(vsn)
    draw_line_v(a1, auxin.closest_vein.position, YELLOW)
  end
end

def add_and_normalize_influences
  @veins.each do |vein|
    v = Raylib::Vector2.create(0, 0)
    influence = vein.influence_vectors.inject(v) do |sum, vector|
      sum = vector2_add(sum, vector)
    end
    a1 = vector2_scale(vector2_normalize(influence), 30)
    a2 = vector2_add(a1, vein.position)
    draw_line_ex(a2, vein.position, 3, RED)
  end
end

@veins = []
@auxins = []

init_window(1200, 1000, 'Leaf venation patterns demo')
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
    recalculate_and_draw_closest_veins
  when :pull_normalized
    show_normalized_closest_veins_vectors
  when :add
    add_and_normalize_influences
  end
  show_info(phase, h - 30)
  end_drawing
end

close_window