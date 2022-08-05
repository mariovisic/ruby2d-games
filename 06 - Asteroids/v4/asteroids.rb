require 'ruby2d'

set title: 'Asteroids'
set width: 800
set height: 600

require './star'
require './player'
require './player_select_screen'
require './game_screen'
require './projectile'
require './asteroid'

current_screen = PlayerSelectScreen.new

update do
  current_screen.update
end

on :key_down do |event|
  case current_screen
  when PlayerSelectScreen
    case event.key
    when 'left'
      current_screen.move(:left)
    when 'right'
      current_screen.move(:right)
    when 'return'
      Window.clear
      current_screen = GameScreen.new(current_screen.selected_player)
    end
  end
end

on :key_held do |event|
  case current_screen
  when GameScreen
    case event.key
    when 'up'
      current_screen.accelerate_player(:forwards)
    when 'down'
      current_screen.accelerate_player(:backwards)
    when 'left'
      current_screen.rotate_player(:left)
    when 'right'
      current_screen.rotate_player(:right)
    when 'space'
      current_screen.player_fire_projectile
    end
  end
end

on :key_up do |event|
  case current_screen
  when GameScreen
    case event.key
    when 'up', 'down'
      current_screen.stop_accelerating_player
    end
  end
end

show
