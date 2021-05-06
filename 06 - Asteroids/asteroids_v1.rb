require 'ruby2d'

set title: 'Asteroids'
set width: 800
set height: 600

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

class Player
  WIDTH = 32 * 3
  HEIGHT = 46 * 3

  attr_reader :x, :y, :speed, :fire_rate

  def initialize(image, x, y, speed, fire_rate)
    @x = x
    @y = y
    @speed = speed
    @fire_rate = fire_rate
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
end

class PlayerSelectScreen
  def initialize
    @stars = Array.new(100).map { Star.new }

    title_text = Text.new('ASTEROIDS', size: 72, y: 40)
    title_text.x = (Window.width - title_text.width) / 2

    player_select_text = Text.new('SELECT YOUR PLAYER', size: 32, y: 120)
    player_select_text.x = (Window.width - player_select_text.width) / 2

    @players = [
      Player.new('player_1.png', Window.width * (1/4.0) - Player::WIDTH / 2, 240, 80, 80),
      Player.new('player_2.png', Window.width * (2/4.0) - Player::WIDTH / 2, 240, 100, 60),
      Player.new('player_3.png', Window.width * (3/4.0) - Player::WIDTH / 2, 240, 60, 100),
    ]

    @selected_player = 1

    animate_players
    add_player_masks
    set_player_stat_text
  end

  def update
    if Window.frames % 2 == 0
      @stars.each { |star| star.move }
    end
  end

  def animate_players
    @players.each_with_index do |player, index|
      if index == @selected_player
        player.animate_fast
      else
        player.animate_slow
      end
    end
  end

  def move(direction)
    if direction == :left
      @selected_player = (@selected_player - 1) % 3
    else
      @selected_player = (@selected_player + 1) % 3
    end

    animate_players
    add_player_masks
    set_player_stat_text
  end

  def add_player_masks
    @player_masks && @player_masks.each { |mask| mask.remove }

    @player_masks = @players.each_with_index.map do |player, index|
      if index == @selected_player
        color = [0.2, 0.2, 0.2, 0.6]
        z = -1
      else
        color = [0.0, 0.0, 0.0, 0.6]
        z = 2
      end

      Circle.new(
        radius: 100,
        sectors: 32,
        x: player.x + (Player::WIDTH / 2),
        y: player.y + (Player::HEIGHT / 2),
        color: color,
        z: z
      )
    end
  end

  def set_player_stat_text
    @player_stat_texts && @player_stat_texts.each { |text| text.remove }

    @player_stat_texts = []
    @players.each_with_index do |player, index|
      if index == @selected_player
        color = Color.new([1,1,1,1])
      else
        color = Color.new([0.3,0.3,0.3,1])
      end

      speed_text = Text.new("Speed - #{player.speed}%", size: 20, y: player.y + 200, color: color)
      speed_text.x = player.x + ((Player::WIDTH - speed_text.width)/2)

      fire_rate_text = Text.new("Fire rate - #{player.fire_rate}%", size: 20, y: player.y + 220, color: color)
      fire_rate_text.x = player.x + ((Player::WIDTH - fire_rate_text.width)/2)

      @player_stat_texts.push(speed_text)
      @player_stat_texts.push(fire_rate_text)
    end

  end
end

player_select_screen = PlayerSelectScreen.new

update do
  player_select_screen.update
end

on :key_down do |event|
  case event.key
  when 'left'
    player_select_screen.move(:left)
  when 'right'
    player_select_screen.move(:right)
  end
end

show
