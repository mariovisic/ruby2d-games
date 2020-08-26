require 'ruby2d'

set background: 'green'

PONG_SOUND = Sound.new('pong.wav')
PING_SOUND = Sound.new('ping.wav')

class NextCoordinates
  def initialize(x, y, x_velocity, y_velocity)
    @x = x
    @y = y
    @x_velocity = x_velocity
    @y_velocity = y_velocity
  end

  def x
    @x + (@x_velocity * [x_length, y_length].min)
  end

  def y
    @y + (@y_velocity * [x_length, y_length].min)
  end

  def hit_top_or_bottom?
    x_length > y_length
  end

  private

  def x_length
    if @x_velocity > 0
      (Window.width - Paddle::X_OFFSET - @x) / @x_velocity
    else
      (@x - Paddle::X_OFFSET) / -@x_velocity
    end
  end

  def y_length
    if @y_velocity > 0
      (Window.height - @y) / @y_velocity
    else
      @y / -@y_velocity
    end
  end

end

class BallTrajectory
  def initialize(ball)
    @ball = ball
  end

  def draw
    next_coordinates = NextCoordinates.new(@ball.x_middle, @ball.y_middle, @ball.x_velocity, @ball.y_velocity)
    line = Line.new(x1: @ball.x_middle, y1: @ball.y_middle, x2: next_coordinates.x, y2: next_coordinates.y, color: 'red', opacity: 0)
    if next_coordinates.hit_top_or_bottom?
      final_coordinates = NextCoordinates.new(next_coordinates.x, next_coordinates.y, @ball.x_velocity, -@ball.y_velocity)
      Line.new(x1: next_coordinates.x, y1: next_coordinates.y, x2: final_coordinates.x, y2: final_coordinates.y, color: 'red', opacity: 0)
    else
      line
    end
  end

  def y_middle
    draw.y2
  end
end

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
  X_OFFSET = 40
  OPPONENT_MOVE_DELAY_FRAMES = 30

  attr_writer :y_movement
  attr_reader :side

  def initialize(side, movement_speed)
    @side = side
    @movement_speed = movement_speed
    @y_movement = 0
    @y = 200
    if side == :left
      @x = X_OFFSET
    else
      @x = Window.width - X_OFFSET
    end
  end

  def move
    @y = (@y + @y_movement * @movement_speed).clamp(0, max_y)
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

  def track_ball(ball_trajectory, last_hit_frame)
    if last_hit_frame + OPPONENT_MOVE_DELAY_FRAMES < Window.frames
      if ball_trajectory.y_middle > y_middle + JITTER_CORRECTION
        @y += @movement_speed
      elsif ball_trajectory.y_middle < y_middle - JITTER_CORRECTION
        @y -= @movement_speed
      end
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

  attr_reader :shape, :x_velocity, :y_velocity

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

  def x_middle
    @x + (HEIGHT / 2)
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
ball_trajectory = BallTrajectory.new(ball)

music = Music.new('music.wav')
music.loop = true
music.play

last_hit_frame = 0

update do
  clear

  DividingLine.new.draw

  if player.hit_ball?(ball)
    ball.bounce_off(player)
    PING_SOUND.play
    last_hit_frame = Window.frames
  end

  if opponent.hit_ball?(ball)
    ball.bounce_off(opponent)
    PING_SOUND.play
    last_hit_frame = Window.frames
  end

  player.move
  player.draw

  ball.move
  ball.draw

  ball_trajectory.draw

  opponent.track_ball(ball_trajectory, last_hit_frame)
  opponent.draw

  if ball.out_of_bounds?
    ball = Ball.new(ball_velocity)
    ball_trajectory = BallTrajectory.new(ball)
  end
end

on :key_held do |event|
  if event.key == 'up'
    player.y_movement = -1
  elsif event.key == 'down'
    player.y_movement = 1
  end
end

on :key_up do |event|
  player.y_movement = 0
end

on :controller_axis do |event|
  if event.axis == :left_y
    player.y_movement = event.value
  end
end

show
