# frozen_string_literal: true

require 'raylib/dsl'
require 'raylib/raymath'
require 'pry'

require_relative 'auxin'
require_relative 'vein'
require_relative 'leaf'
require_relative 'renderer'

#
# Leaf venation visualization
#
# First version - the goal is to just implement the algorithm
# in simplest form - it will be then base to further refactorings ;-)
#

PHASE = [
  { key: :init, desc: 'Initial state' },
  { key: :pull, desc: 'Discover veins affected' },
  { key: :pull_normalized, desc: 'Normalize vectors to auxin\'s closest vein' },
  { key: :add, desc: 'Add all vectors to auxin\'s closest vein' },
  { key: :grow, desc: 'Grow new vein' },
  { key: :populate, desc: 'Populate new auxin sources' }
].freeze

PHASES = PHASE.cycle

@phase = PHASES.next
@populated = false
@show_auximity = false
@show_vein_proximity = false

def show_info(phase, top)
  Renderer.show_info "#{PHASE.index(phase) + 1}. [#{phase[:key]}] - #{phase[:desc]}.", 20, top
end

def render(height)
  clear_background(get_color(0x181818FF))
  @leaf.show_veins(show_proximity: @show_vein_proximity)
  @leaf.show_auxins(show_auximity: @show_auximity)
  case @phase[:key]
  when :pull
    @leaf.recalculate_and_draw_closest_veins
  when :pull_normalized
    @leaf.show_normalized_closest_veins_vectors
  when :add
    @leaf.add_and_normalize_influences
  when :grow
    @leaf.grow_new_vein
  when :populate
    @populated ||= @leaf.populate_new_auxins
  end
  show_info(@phase, height - 30)
end

@veins = []
@auxins = []

init_window(1200, 1000, 'Leaf venation patterns demo')
w = get_screen_width
h = get_screen_height

@leaf = Leaf.new(w, h)

@leaf.add_veins
@leaf.add_auxins

until window_should_close
  if is_key_pressed(KEY_SPACE)
    @populated = false
    @phase = PHASES.next
  end

  @show_auximity = !@show_auximity if is_key_pressed(KEY_A)

  @show_vein_proximity = !@show_vein_proximity if is_key_pressed(KEY_V)

  begin_drawing
  render(h)
  end_drawing
end

close_window
