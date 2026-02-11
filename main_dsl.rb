require 'raylib/dsl'
require 'pry'

PHASE = [
  'Initial state',
  'Discover veins affected'
]
PHASES = PHASE.cycle

phase = PHASES.first

def show_info(phase, top)
  draw_text("#{PHASE.index(phase) + 1}. #{phase}.", 20, top, 21, LIGHTGRAY)
end

init_window(1200, 900, 'Leaf venation patterns demo')
w = get_screen_width
h = get_screen_height

until window_should_close
  if is_key_pressed(KEY_SPACE)
    phase = PHASES.next
  end
  
  begin_drawing
  clear_background(get_color(0x181818FF))
  show_info(phase, h - 30)
  end_drawing
end

close_window