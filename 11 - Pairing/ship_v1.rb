require 'ruby2d'

GRID_SIZE = 64

set background: 'blue'

set width: 64 * 12
set height: 64 * 10

class Player
  def initialize
    @ship = Image.new(
      'pirate_assets/PNG/Retina/Ships/ship.png',
      rotate: 180,
      x: 100, y: 200,
    )

    @velocity = 0
    @rotate = 0
  end

  def move    
    x_component = Math.sin(@ship.rotate * Math::PI / 180)
    y_component = Math.cos(@ship.rotate * Math::PI / 180)

    @ship.x += x_component * @velocity
    @ship.y -= y_component * @velocity
  end

  def increase_velocity
    @velocity += 0.01
  end

  def decrease_velocity
    @velocity -= 0.01
  end

  # Turning left
  def turn_port
    @ship.rotate -= 1
  end

  # Turning right
  def turn_starboard
    @ship.rotate += 1
  end
end

tileset = Tileset.new(
  'pirate_assets/Tilesheet/tiles_sheet.png',
  tile_width: GRID_SIZE,
  tile_height: GRID_SIZE,
)

tileset.define_tile('ocean', 8, 4)

(Window.width / GRID_SIZE).times do |x|
  (Window.height / GRID_SIZE).times do |y|
    tileset.set_tile('ocean', [{ x: x * GRID_SIZE, y: y * GRID_SIZE }])
  end
end

tileset.define_tile('top_left_corner', 5, 0)
tileset.set_tile('top_left_corner', [{ x: 5 * GRID_SIZE, y: 4 * GRID_SIZE }])
tileset.define_tile('top_right_corner', 8, 0)
tileset.set_tile('top_right_corner', [{ x: 6 * GRID_SIZE, y: 4 * GRID_SIZE }])
tileset.define_tile('bottom_left_corner', 5, 3)
tileset.set_tile('bottom_left_corner', [{ x: 5 * GRID_SIZE, y: 5 * GRID_SIZE }])
tileset.define_tile('bottom_right_corner', 8, 3)
tileset.set_tile('bottom_right_corner', [{ x: 6 * GRID_SIZE, y: 5 * GRID_SIZE }])

player = Player.new

on :key_held do |event|
  case event.key
  when 'up'
    player.decrease_velocity
  when 'down'
    player.increase_velocity
  when 'left'
    player.turn_port
  when 'right'
    player.turn_starboard
  end
end


update do
  player.move
end

show