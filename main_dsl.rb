require 'raylib/dsl'
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

PHASE = [
  'Initial state',
  'Discover veins affected'
]
PHASES = PHASE.cycle

phase = PHASES.next

def show_info(phase, top)
  draw_text("#{PHASE.index(phase) + 1}. #{phase}.", 20, top, 21, LIGHTGRAY)
end

def show_veins
  @veins.each do |v|
    draw_circle(v.position.x, v.position.y, v.radius, v.color)
    draw_circle(v.position.x, v.position.y, v.inner_radius, v.inner_color)
  end
end

@veins = []

init_window(1200, 900, 'Leaf venation patterns demo')
w = get_screen_width
h = get_screen_height

position = Raylib::Vector2.create(w/2, h/4*3)

vein = Vein.new(position)
@veins.push(vein)

until window_should_close
  if is_key_pressed(KEY_SPACE)
    phase = PHASES.next
  end

  begin_drawing
  clear_background(get_color(0x181818FF))
  show_veins
  show_info(phase, h - 30)
  end_drawing
end

close_window