require 'ruby2d'

set width: 192
set height: 192

tileset = Ruby2D::Tileset.new('tilemap.png', spacing: 1, tile_width: 16, tile_height: 16, scale: 4)

tileset.define_tile('mushroom', 0, 3)
tileset.define_tile('mushroom-rotated', 0, 3, rotate: 90)
tileset.define_tile('mushroom-flipped', 0, 3, flip: :horizontal)
tileset.define_tile('flowers', 2, 3)

tileset.set_tile('mushroom', [
  { x: 0, y: 0 },
  { x: 128, y: 128 },
])


tileset.set_tile('mushroom-rotated', [
  { x: 64, y: 0 },
])

tileset.set_tile('mushroom-flipped', [
  { x: 0, y: 64 },
])

tileset.set_tile('flowers', [
  { x: 64, y: 64 },
  { x: 64, y: 128 },
])

show