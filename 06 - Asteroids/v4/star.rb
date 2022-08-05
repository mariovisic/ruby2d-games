class Star
  def initialize
    @y_velocity = rand(-5..0)
    @shape = Circle.new(
      x: rand(Window.width),
      y: rand(Window.height),
      radius: rand(1..2),
      color: 'random',
      z: -2
    )
  end

  def move
    @shape.y = (@shape.y + @y_velocity) % Window.height
  end
end