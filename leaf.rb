# frozen_string_literal: true

class Leaf
  attr_reader :veins, :auxins

  AUXIN_CREATION_RATE = 3
  VEIN_PROXIMITY = 50
  AUXIMITY = 60

  def initialize(width, height)
    # for now the "leaf" area is just rectangle (ie. screen)
    @width = width
    @height = height
    @veins = []
    @auxins = []
  end

  def add_veins
    # probably unnecessary dependency
    position = Raylib::Vector2.create(@width / 2, @height / 4 * 3)

    vein = Vein.new(position)
    @veins.push(vein)
  end

  def add_auxins
    (1..AUXIN_CREATION_RATE).each do
      position = Raylib::Vector2.create(rand(@width), rand(@height))

      auxin = Auxin.new(position)
      @auxins.push(auxin)
    end
  end

  def show_veins(show_proximity: false)
    veins.each do |v|
      Renderer.render_vein(v, VEIN_PROXIMITY, show_proximity)
    end
  end

  def show_auxins(show_auximity: false)
    auxins.each do |a|
      Renderer.render_auxin(a, AUXIMITY, show_auximity)
    end
  end

  def recalculate_and_draw_closest_veins
    recalculate_closest_veins
    render_closest_veins
  end

  def show_normalized_closest_veins_vectors
    veins.each(&:reset_influence)

    calculate_vein_influences
    render_vein_influences
  end

  def add_and_normalize_influences
    veins_with_influence.each do |vein|
      v = Raylib::Vector2.create(0, 0)
      influence = vein.influence_vectors.inject(v) do |sum, vector|
        sum = vector2_add(sum, vector)
      end
      a1 = vector2_scale(vector2_normalize(influence), vein.radius * 2)
      a2 = vector2_add(a1, vein.position)
      vein.save_new_growth_position(a2)
    end

    render_vein_growth_vector
  end

  def grow_new_vein
    veins_with_influence.each do |vein|
      auxins_to_remove = []
      new_growth_pos = vein.fetch_new_growth_position

      if new_growth_pos
        new_vein = Vein.new(new_growth_pos)
        veins.push(new_vein)
        vein.clear_growth_position

        auxins.each do |auxin|
          if vector2_distance(auxin.position, new_vein.position) <= VEIN_PROXIMITY
            auxins_to_remove << auxins.index(auxin)
          end
        end
      end

      @auxins = @auxins.reject do |auxin|
        auxins_to_remove.include?(@auxins.index(auxin))
      end
    end
  end

  def populate_new_auxins
    n = 0
    while n < AUXIN_CREATION_RATE
      position = Raylib::Vector2.create(rand(@width), rand(@height))

      correct_auxin_position = true
      auxins.each do |auxin|
        correct_auxin_position = false if vector2_distance(position, auxin.position) <= AUXIMITY
      end

      veins.each do |vein|
        correct_auxin_position = false if vector2_distance(position, vein.position) <= VEIN_PROXIMITY
      end

      next unless correct_auxin_position

      auxin = Auxin.new(position)
      @auxins.push(auxin)
      n += 1
    end

    true
  end

  private

  def recalculate_closest_veins
    auxins.each do |auxin|
      auxin.closest_vein = veins.first
      veins.each do |vein|
        if vector2_distance(vein.position,
                            auxin.position) < vector2_distance(auxin.closest_vein.position, auxin.position)
          auxin.closest_vein = vein
        end
      end
    end
  end

  def render_closest_veins
    auxins.each do |auxin|
      Renderer.render_closest_veins(auxin.closest_vein.position, auxin.position, WHITE)
    end
  end

  def calculate_vein_influences
    auxins.each do |auxin|
      vs = vector2_subtract(auxin.position, auxin.closest_vein.position)
      vsn = vector2_scale(vector2_normalize(vs), 50)
      auxin.closest_vein.add_influence(vsn)
    end
  end

  def render_vein_influences
    veins_with_influence.each do |vein|
      vein.influence_vectors.each do |influence_vector|
        position = vector2_add(influence_vector, vein.position)
        draw_line_v(position, vein.position, YELLOW)
      end
    end
  end

  def veins_with_influence
    veins.filter do |vein|
      vein.influence_vectors.any?
    end
  end

  def render_vein_growth_vector
    veins_with_influence.each do |vein|
      draw_line_ex(vein.fetch_new_growth_position, vein.position, 3, RED)
    end
  end
end
