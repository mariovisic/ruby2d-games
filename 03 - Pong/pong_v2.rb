require 'ruby2d'

set background: 'green'

PONG_SOUND = Sound.new('pong.wav')
PING_SOUND = Sound.new('ping.wav')

class DividingLine
  WIDTH = 15
  HEIGHT = 25
  NUMBER_OF_LINES = 10

  def draw
    NUMBER_OF_LINES.times do |i|
      Rectangle.new(x: (Window.width + WIDTH) / 2, y: (Window.height / NUMBER_OF_LINES) * i, height: HEIGHT, width: WIDTH, color: 'white')
    end
  end
end

class Paddle
  HEIGHT = 150
  JITTER_CORRECTION = 4

  attr_writer :direction
  attr_reader :side

  def initialize(side, movement_speed)
    @side = side
    @movement_speed = movement_speed
    @direction = nil
    @y = 200
    if side == :left
      @x = 40
    else
      @x = 600
    end
  end

  def move
    if @direction == :up
      @y = [@y - @movement_speed, 0].max
    elsif @direction == :down
      @y = [ @y + @movement_speed, max_y].min
    end
  end

  def draw
    @shape = Rectangle.new(x: @x, y: @y, width: 25, height: HEIGHT, color: 'white')
  end

  def hit_ball?(ball)
    ball.shape && [[ball.shape.x1, ball.shape.y1], [ball.shape.x2, ball.shape.y2],
     [ball.shape.x3, ball.shape.y3], [ball.shape.x4, ball.shape.y4]].any? do |coordinates|
      @shape.contains?(coordinates[0], coordinates[1])
    end
  end

  def track_ball(ball)
    if ball.y_middle > y_middle + JITTER_CORRECTION
      @y += @movement_speed
    elsif ball.y_middle < y_middle - JITTER_CORRECTION
      @y -= @movement_speed
    end
  end

  def y1
    @shape.y1
  end

  private

  def y_middle
    @y + (HEIGHT / 2)
  end

  def max_y
    Window.height - HEIGHT
  end
end

class Ball
  HEIGHT = 25

  attr_reader :shape

  def initialize(speed)
    @x = 320
    @y = 400
    @speed = speed
    @y_velocity = speed
    @x_velocity = -speed
  end

  def move
    if hit_bottom? || hit_top?
      PONG_SOUND.play
      @y_velocity = -@y_velocity
    end

    @x = @x + @x_velocity
    @y = @y + @y_velocity
  end

  def draw
    @shape = Square.new(x: @x, y: @y, size: HEIGHT, color: 'yellow')
  end

  def bounce_off(paddle)
    if @last_hit_side != paddle.side
      position = ((@shape.y1 - paddle.y1) / Paddle::HEIGHT.to_f)
      angle = position.clamp(0.2, 0.8) * Math::PI

      if paddle.side == :left
        @x_velocity = Math.sin(angle) * @speed
        @y_velocity = -Math.cos(angle) * @speed
      else
        @x_velocity = -Math.sin(angle) * @speed
        @y_velocity = -Math.cos(angle) * @speed
      end

      @last_hit_side = paddle.side
    end
  end

  def y_middle
    @y + (HEIGHT / 2)
  end

  def out_of_bounds?
    @x <= 0 || @shape.x2 >= Window.width
  end

  private


  def hit_bottom?
    @y + HEIGHT >= Window.height
  end

  def hit_top?
    @y <= 0
  end
end


ball_velocity = 8

player = Paddle.new(:left, 5)
opponent = Paddle.new(:right, 3)
ball = Ball.new(ball_velocity)

music = Music.new('music.wav')
music.loop = true
music.play

update do
  clear

  DividingLine.new.draw

  if player.hit_ball?(ball)
    ball.bounce_off(player)
    PING_SOUND.play
  end

  if opponent.hit_ball?(ball)
    ball.bounce_off(opponent)
    PING_SOUND.play
  end

  player.move
  player.draw

  opponent.track_ball(ball)
  opponent.draw

  ball.move
  ball.draw

  if ball.out_of_bounds?
    ball = Ball.new(ball_velocity)
  end
end

on :key_held do |event|
  if event.key == 'up'
    player.direction = :up
  elsif event.key == 'down'
    player.direction = :down
  end
end

on :key_up do |event|
  player.direction = nil
end


show
