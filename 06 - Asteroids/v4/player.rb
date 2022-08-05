class Player
  WIDTH = 32 * 3
  HEIGHT = 46 * 3
  ROTATE_SPEED = 5
  VELOCITY_INCREASE_SPEED = 0.2
  MAX_VELOCITY = 10
  SLOW_DOWN_RATE = 0.99

  attr_reader :image, :x, :y, :speed, :fire_rate

  def initialize(image, x, y, speed, fire_rate)
    @x_velocity = 0
    @y_velocity = 0
    @image = image
    @x = x
    @y = y
    @speed = speed
    @fire_rate = fire_rate
    @projectiles = []
    @last_projectile_fired_frame = 0
    @sprite = Sprite.new(
      image,
      clip_width: 32,
      width: WIDTH,
      height: HEIGHT,
      x: x,
      y: y,
      rotate: 180,
      animations: {
        moving_slow: 1..2,
        moving_fast: 3..4
      }
    )
  end

  def animate_slow
    @sprite.play(animation: :moving_slow, loop: true)
  end

  def animate_fast
    @sprite.play(animation: :moving_fast, loop: true)
  end

  def rotate(direction)
    case direction
    when :left
      @sprite.rotate -= ROTATE_SPEED
    when :right
      @sprite.rotate += ROTATE_SPEED
    end
  end

  def accelerate(direction)
    animate_fast

    x_component = Math.sin(@sprite.rotate * Math::PI / 180) * VELOCITY_INCREASE_SPEED * (@speed / 100.0)
    y_component = Math.cos(@sprite.rotate * Math::PI / 180) * VELOCITY_INCREASE_SPEED * (@speed / 100.0)

    case direction
    when :forwards
      @x_velocity += x_component
      @y_velocity -= y_component
    when :backwards
      @x_velocity -= x_component
      @y_velocity += y_component
    end

    total_velocity = @x_velocity.abs + @y_velocity.abs

    if total_velocity > MAX_VELOCITY
      @x_velocity = @x_velocity * (MAX_VELOCITY / total_velocity)
      @y_velocity = @y_velocity * (MAX_VELOCITY / total_velocity)
    end
  end

  def move
    @sprite.x += @x_velocity
    @sprite.y += @y_velocity

    if @sprite.x > Window.width + @sprite.width
      @sprite.x = -@sprite.width
    elsif @sprite.x < -@sprite.width
      @sprite.x = Window.width + @sprite.width
    end

    if @sprite.y > Window.height + @sprite.height
      @sprite.y = -@sprite.height
    elsif @sprite.y < -@sprite.height
      @sprite.y = Window.height + @sprite.height
    end

    @projectiles.each do |projectile|
      projectile.move
    end
  end

  def slow_down
    @x_velocity *= SLOW_DOWN_RATE
    @y_velocity *= SLOW_DOWN_RATE
  end

  def stop_accelerating
    animate_slow
  end

  def fire_projectile
    if @last_projectile_fired_frame + 25 - (@fire_rate / 10) < Window.frames
      x_component = Math.sin(@sprite.rotate * Math::PI / 180)
      y_component = -Math.cos(@sprite.rotate * Math::PI / 180)

      x = @sprite.x + (@sprite.width * 0.5) + (x_component * @sprite.width)
      y = @sprite.y + (@sprite.height * 0.5) + (y_component * @sprite.height)
      direction = 0

      @projectiles.push(Projectile.new(x, y, @sprite.rotate))
      @projectiles = @projectiles.last(20)
      @last_projectile_fired_frame = Window.frames
    end
  end
end