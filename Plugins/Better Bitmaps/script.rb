#==============================================================================
#                                Better Bitmaps                                #
#                                   by Marin                                   #
#==============================================================================
#    This is a script that allows you to draw all sorts of complex shapes      #
#                      with all sorts of colors and angles.                    #
#                                                                              #
#    An example usage for "draw_hexagon_with_values" would be a display of a   #
#                    Pokémon's statistics in the Summary screen.               #
#                                                                              #
#       Most methods can be seen in action at the bottom of the script.        #
#                                                                              #
#        All the methods themselves have been documented and explained.        #
#                           I am open to questions.                            #
#==============================================================================
#                    Please give credit when using this.                       #
#==============================================================================

# Shortcuts for commonly used colors
# Usage:
#  -> Color::White
#  -> Color::Alpha
#  -> Color::Green
class Color
  White = Color.new(255,255,255)
  Black = Color.new(0,0,0)
  Alpha = Color.new(255,255,255,0)
  Red   = Color.new(255,0,0)
  Green = Color.new(0,255,0)
  Blue  = Color.new(0,0,255)
end

class Sprite
  def draw_line(*args)
    self.bitmap.draw_line(*args)
  end
  def draw_shape(color, points, fill = false)
    self.bitmap.draw_shape(color, points, fill)
  end
  def draw_shape_with_values(color, x, y, points, max_value, values, fill = false, outline = true)
    self.bitmap.draw_shape_with_values(color, x, y, points, max_value, values, fill, outline)
  end
  def draw_hexagon(x, y, width, height, color, y_offset = nil, fill = false)
    self.bitmap.draw_hexagon(x, y, width, height, color, y_offset, fill)
  end
  def draw_hexagon_with_values(x, y, width, height, color, max_value, values, y_offset = nil, fill = false, outline = true)
    self.bitmap.draw_hexagon_with_values(x, y, width, height, color, max_value, values, y_offset, fill, outline)
  end
  def draw_triangle(x, y, width, height, color, fill = false)
    self.bitmap.draw_triangle(x, y, width, height, color, fill)
  end
  def draw_rectangle(x, y, width, height, color, fill = false)
    self.bitmap.draw_rectangle(x, y, width, height, color, fill)
  end
  alias draw_rect draw_rectangle
  def draw_circle(x, y, color, radius, fill = false)
    self.bitmap.draw_circle(x, y, color, radius, fill)
  end
  def draw_ellipse(x, y, width, height, color, fill = false, preciseness = 100)
    self.bitmap.draw_ellipse(x, y, width, height, color, fill, preciseness)
  end
end

class Point
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Bitmap
  private
  def self.get_table(x1, y1, x2, y2)
    table = []
    x1, y1, x2, y2 = x1.round, y1.round, x2.round, y2.round
    unless x1 == x2
      for x in (x1 > x2 ? x2..x1 : x1..x2)
        fact = (x - x1) / (x2 - x1).to_f
        table << [x, (y1 + ((y2 - y1).to_f * fact)).round]
      end
    end
    unless y1 == y2
      for y in (y1 > y2 ? y2..y1 : y1..y2)
        fact = (y - y1) / (y2 - y1).to_f
        table << [(x1 + ((x2 - x1).to_f * fact)).round, y]
      end
    end
    return table
  end
  public
  def draw_line(*args)
    i = 0
    if args[0].is_a?(Point)
      x1 = args[0].x
      y1 = args[0].y
      i += 1
    elsif args[0].is_a?(Array)
      x1 = args[0][0]
      y1 = args[0][1]
      i += 1
    else
      x1 = args[0]
      y1 = args[1]
      i += 2
    end
    if args[i].is_a?(Point)
      x2 = args[i].x
      y2 = args[i].y
      i += 1
    elsif args[i].is_a?(Array)
      x2 = args[i][0]
      y2 = args[i][1]
      i += 1
    else
      x2 = args[i]
      y2 = args[i + 1]
      i += 2
    end
    x1, y1, x2, y2 = x1.round, y1.round, x2.round, y2.round
    color = args[i]
    table = []
    unless x1 == x2
      for x in (x1 > x2 ? x2..x1 : x1..x2)
        fact = (x - x1) / (x2 - x1).to_f
        y = (y1 + ((y2 - y1).to_f * fact)).round
        set_pixel(x, y, color)
        table[x] = y
      end
    end
    unless y1 == y2
      for y in (y1 > y2 ? y2..y1 : y1..y2)
        fact = (y - y1) / (y2 - y1).to_f
        x = (x1 + ((x2 - x1).to_f * fact)).round
        set_pixel(x, y, color)
        table[x] = y
      end
    end
    return table
  end
  def draw_shape(color, points, fill = false)
    if points.size == 0
      raise "Must specify at least one point to draw a shape"
    end
    tables = []
    i = 0
    while i < points.size
      x1, y1, x2, y2 = nil
      if points[i].is_a?(Point)
        x1 = points[i].x
        y1 = points[i].y
      else
        x1 = points[i][0]
        y1 = points[i][1]
      end
      i += 1
      break unless i < points.size
      if points[i].is_a?(Point)
        x2 = points[i].x
        y2 = points[i].y
      else
        x2 = points[i][0]
        y2 = points[i][1]
      end
      tables << draw_line(x1, y1, x2, y2, color)
    end
    table = {}
    for e in tables
      for i in 0...e.size
        next unless e[i]
        table[i] ||= []
        table[i] << e[i]
      end
    end
    if fill
      s = Time.now
      xvals = points.map { |e| e.respond_to?(:x) ? e.x : e[0] }
      yvals = points.map { |e| e.respond_to?(:y) ? e.y : e[1] }
      for px in (xvals.min + 1)...(xvals.max)
        for py in (yvals.min + 1)...(yvals.max)
          if table[px] && py > table[px].min && py < table[px].max
            set_pixel(px, py, color)
            if Time.now - s > 3
              Graphics.update
              s = Time.now
            end
          end
        end
      end
    end
    return tables
  end
  def draw_shape_with_values(color, x, y, points, max_value, values, fill = false, outline = true)
    coords = []
    values.each_with_index do |v,i|
      fact = v.to_f / max_value
      fact = 1.0 if fact > 1
      px = points[i].is_a?(Point) ? points[i].x : points[i][0]
      py = points[i].is_a?(Point) ? points[i].y : points[i][1]
      table = Bitmap.get_table(px, py, x, y).sort { |a,b| a[0] <=> b[0] }
      entry_count = (table.size * fact).round
      table.reverse! if px > x
      point = table[table.size - entry_count]
      point ||= [x, y]
      coords << Point.new(*point)
    end
    table = draw_shape(color, coords.concat([coords[0]]), fill)
    draw_shape(color, points.concat([points[0]])) if outline
    return table
  end
  def draw_hexagon(x, y, width, height, color, y_offset = nil, fill = false)
    yp = y_offset || (height / 4.0).floor
    points = []
    points[5] = Point.new(x - (width / 2.0).round, y - (height / 2.0).round + yp)
    points[4] = Point.new(x - (width / 2.0).round, y + (height / 2.0).round - yp)
    points[3] = Point.new(x, y + (height / 2.0).round)
    points[2] = Point.new(x + (width / 2.0).round, points[4].y)
    points[1] = Point.new(x + (width / 2.0).round, points[5].y)
    points[0] = Point.new(x, y - (height / 2.0).round)
    return draw_shape(color, points.concat([points[0]]), fill)
  end
  def draw_hexagon_with_values(x, y, width, height, color, max_value, values, y_offset = nil, fill = false, outline = true)
    yp = y_offset || (height / 4.0).floor
    points = []
    points[5] = Point.new(x - (width / 2.0).round, y - (height / 2.0).round + yp)
    points[4] = Point.new(x - (width / 2.0).round, y + (height / 2.0).round - yp)
    points[3] = Point.new(x, y + (height / 2.0).round)
    points[2] = Point.new(x + (width / 2.0).round, points[4].y)
    points[1] = Point.new(x + (width / 2.0).round, points[5].y)
    points[0] = Point.new(x, y - (height / 2.0).round)
    return draw_shape_with_values(color, x, y, points, max_value, values, fill, outline)
  end
  def draw_triangle(x, y, width, height, color, fill = false)
    points = []
    points[0] = Point.new(x - (width / 2.0).round, y + (height / 2.0).round)
    points[1] = Point.new(x, y - (height / 2.0).round)
    points[2] = Point.new(x + (width / 2.0).round, points[0].y)
    return draw_shape(color, points.concat([points[0]]), fill)
  end
  def draw_rectangle(x, y, width, height, color, fill = false)
    hw, hh = (width / 2.0).round, (height / 2.0).round
    return draw_shape(color, [
        Point.new(x - hw, y - hh),
        Point.new(x - hw, y + hh),
        Point.new(x + hw, y + hh),
        Point.new(x + hw, y - hh),
        Point.new(x - hw, y - hh)], fill)
  end
  alias draw_rect draw_rectangle
  def draw_circle(ox, oy, color, radius, fill = false)
    x = radius - 1
    y = 0
    dx = 1
    dy = 1
    err = dx - (radius << 1)
    table = {}
    while x >= y
      set_pixel(ox - x, oy - y, color)
      set_pixel(ox - x, oy + y, color)
      set_pixel(ox + x, oy - y, color)
      set_pixel(ox + x, oy + y, color)
      set_pixel(ox - y, oy - x, color)
      set_pixel(ox - y, oy + x, color)
      set_pixel(ox + y, oy - x, color)
      set_pixel(ox + y, oy + x, color)
      if fill
        table[ox - x] ||= []; table[ox - x] << oy - y
        table[ox - x] ||= []; table[ox - x] << oy + y
        table[ox + x] ||= []; table[ox + x] << oy - y
        table[ox + x] ||= []; table[ox + x] << oy + y
        table[ox - y] ||= []; table[ox - y] << oy - x
        table[ox - y] ||= []; table[ox - y] << oy + x
        table[ox + y] ||= []; table[ox + y] << oy - x
        table[ox + y] ||= []; table[ox + y] << oy + x
      end
      if err <= 0
        y += 1
        err += dy
        dy += 2
      end
      if err > 0
        x -= 1
        dx += 2
        err += dx - (radius << 1)
      end
    end
    if fill
      for px in (ox - radius + 1)...(ox + radius)
        for py in (oy - radius + 1)...(oy + radius)
          if table[px] && py > table[px].min && py < table[px].max
            set_pixel(px, py, color)
          end
        end
      end
    end
  end
  def draw_ellipse(ox, oy, width, height, color, fill = false, preciseness = 100)
    width /= 2.0
    height /= 2.0
    t = 0
    points = []
    while t < 2.0 * Math::PI
      points << Point.new((ox + width * Math.cos(t)).round, (oy - height * Math.sin(t)).round)
      t += 2.0 * Math::PI / preciseness.to_f
    end
    return draw_shape(color, points.concat([points[0]]), fill)
  end
end
