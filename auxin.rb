# frozen_string_literal: true

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
