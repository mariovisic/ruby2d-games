require 'ruby2d'

set background: 'orange'

fish = Sprite.new('fish.png', x: 200, y: 200, width: 128, height: 128)

hitboxes = [
  Square.new(x: fish.x + 5, y: fish.y + 45, color: [1, 0, 1, 0.4], size: 50),
  Square.new(x: fish.x + 50, y: fish.y + 45, color: [1, 0, 1, 0.4], size: 50),
  Square.new(x: fish.x + 50, y: fish.y + 25, color: [1, 0, 1, 0.4], size: 50),
  Square.new(x: fish.x + 50, y: fish.y + 60, color: [1, 0, 1, 0.4], size: 50),
  Square.new(x: fish.x + 72, y: fish.y + 45, color: [1, 0, 1, 0.4], size: 50),
]

on :mouse_move do |event|
  if hitboxes.any? { |hitbox| hitbox.contains?(event.x.to_i, event.y.to_i) }
    fish.color.g = 0
  else
    fish.color.g = 1
  end
end

show