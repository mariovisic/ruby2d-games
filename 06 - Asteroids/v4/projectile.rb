class Projectile
  WIDTH = 6 * 3
  HEIGHT = 6 * 3
  SPEED = 12

  def initialize(x, y, rotate)
    Sound.new('laser.ogg').play

    @image = Sprite.new(
      'projectile.png',
      x: x,
      y: y,
      width: WIDTH,
      height: HEIGHT,
      rotate: rotate,
    )

    @x_velocity = Math.sin(@image.rotate * Math::PI / 180) * SPEED
    @y_velocity = -Math.cos(@image.rotate * Math::PI / 180) * SPEED
  end

  def move
    @image.x += @x_velocity
    @image.y += @y_velocity
  end
end