require 'raylib/dsl'

module Renderer
  class << self
    def show_info(msg, pos_x, pos_y, font_size: 21, color: LIGHTGRAY)
      draw_text(msg, pos_x, pos_y, font_size, color)
    end

    def render_vein(vein, proximity_radius, show_proximity)
      draw_circle(vein.position.x, vein.position.y, vein.radius, vein.color)
      draw_circle(vein.position.x, vein.position.y, vein.inner_radius, vein.inner_color)
      return unless show_proximity

      draw_circle_lines(vein.position.x, vein.position.y, proximity_radius,
                        vein.color)
    end

    def render_auxin(auxin, auximity_radius, show_auximity)
      draw_circle(auxin.position.x, auxin.position.y, auxin.radius, auxin.color)
      draw_circle_lines(auxin.position.x, auxin.position.y, auximity_radius, auxin.color) if show_auximity
    end

    def render_closest_veins(pos1, pos2, color)
      draw_line_v(pos1, pos2, color)
    end
  end
end
