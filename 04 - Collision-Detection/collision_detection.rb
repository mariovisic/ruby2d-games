require 'ruby2d'

set background: 'white'
set width: 1200
set height: 800

class Box
  def initialize
    @x = rand(Window.width)
    @y = rand(Window.height)
    @x_velocity = (-5..5).to_a.sample
    @y_velocity = (-5..5).to_a.sample
    @color = Color.new('random')
    @size = (6..20).to_a.sample
  end

  def draw
    @square = Square.new(x: @x, y: @y, size: @size, color: @color)
  end

  def move
    @x = (@x + @x_velocity) % Window.width
    @y = (@y + @y_velocity) % Window.height
  end

  def check_for_collisions
    if @square && colission_detected?
      @x_velocity = -@x_velocity
      @y_velocity = -@y_velocity
    end
  end

  def colission_detected?
    ($boxes - Array(self)).any? do |other_box|
      other_box.include?(@square)
    end
  end

  def include?(other_square)
    @square.contains?(other_square.x1, other_square.y1) ||
    @square.contains?(other_square.x2, other_square.y2) ||
    @square.contains?(other_square.x3, other_square.y3) ||
    @square.contains?(other_square.x4, other_square.y4)
  end
end

$boxes = Array.new(40) { Box.new }

update do
  clear
  $boxes.each do |box|
    box.check_for_collisions
    box.move
    box.draw
  end
end

show
