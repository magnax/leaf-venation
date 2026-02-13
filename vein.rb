# frozen_string_literal: true

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
