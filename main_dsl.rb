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
    @new_growth_position = nil
  end

  def reset_influence
    @influence_vectors = []
  end

  def add_influence(vector)
    @influence_vectors.push(vector)
  end

  def save_new_growth_position(pos)
    @new_growth_position = pos
  end

  def fetch_new_growth_position
    @new_growth_position
  end

  def clear_growth_position
    @new_growth_position = nil
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
  {key: :add, desc: 'Add all vectors to auxin\'s closest vein'},
  {key: :grow, desc: 'Grow new vein'},
  {key: :populate, desc: 'Populate new auxin sources'}
]
PHASES = PHASE.cycle
AUXIN_CREATION_RATE = 3
AUXIMITY = 50
VEIN_PROXIMITY = 50

phase = PHASES.next
@populated = false
@show_auximity = false
@show_vein_proximity = false

def show_info(phase, top)
  draw_text("#{PHASE.index(phase) + 1}. [#{phase[:key].to_s}] - #{phase[:desc]}.", 20, top, 21, LIGHTGRAY)
end

def show_veins
  @veins.each do |v|
    draw_circle(v.position.x, v.position.y, v.radius, v.color)
    draw_circle(v.position.x, v.position.y, v.inner_radius, v.inner_color)
    draw_circle_lines(v.position.x, v.position.y, VEIN_PROXIMITY, get_color(0x2222ffff)) if @show_vein_proximity
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
    draw_circle_lines(v.position.x, v.position.y, AUXIMITY, get_color(0xff2222ff)) if @show_auximity
  end
end

def recalculate_and_draw_closest_veins
  @auxins.each do |auxin|
    auxin.closest_vein = @veins.first
    @veins.each do |vein|
      if vector2_distance(vein.position, auxin.position) < vector2_distance(auxin.closest_vein.position, auxin.position)
        auxin.closest_vein = vein
      end
    end
    draw_line_v(auxin.closest_vein.position, auxin.position, WHITE)
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
    a1 = vector2_scale(vector2_normalize(influence), vein.radius * 2)
    a2 = vector2_add(a1, vein.position)
    vein.save_new_growth_position(a2)
    draw_line_ex(a2, vein.position, 3, RED)
  end
end

def grow_new_vein
  @veins.each do |vein|
    auxins_to_remove = []
    new_growth_pos = vein.fetch_new_growth_position
    
    if new_growth_pos
      new_vein = Vein.new(new_growth_pos)
      @veins.push(new_vein)
      vein.clear_growth_position

      @auxins.each do |auxin|
        if vector2_distance(auxin.position, new_vein.position) <= VEIN_PROXIMITY
          auxins_to_remove << @auxins.index(auxin)
        end
      end
    end
    
    @auxins = @auxins.reject { |auxin| auxins_to_remove.include?(@auxins.index(auxin)) }
  end
end

def populate_new_auxins(w, h)
  n = 0
  while n < AUXIN_CREATION_RATE
    position = Raylib::Vector2.create(rand(w), rand(h))

    correct_auxin_position = true
    @auxins.each do |auxin|
      if vector2_distance(position, auxin.position) <= AUXIMITY
        correct_auxin_position = false
      end
    end

    @veins.each do |vein|
      if vector2_distance(position, vein.position) <= VEIN_PROXIMITY
        correct_auxin_position = false
      end
    end

    if correct_auxin_position
      auxin = Auxin.new(position)
      @auxins.push(auxin)
      n +=1
    end
  end 
  @populated = true
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
    @populated = false
    phase = PHASES.next
  end

  if is_key_pressed(KEY_A)
    @show_auximity = !@show_auximity
  end

  if is_key_pressed(KEY_V)
    @show_vein_proximity = !@show_vein_proximity
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
  when :grow
    grow_new_vein
  when :populate
    populate_new_auxins(w, h) unless @populated
  end
  show_info(phase, h - 30)
  end_drawing
end

close_window