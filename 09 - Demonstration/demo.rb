require 'ruby2d'

set width: 640
set height: 480

Image.new('background.png')

Circle.new(
  color: 'yellow',
  x: 20,
  y: 20,
  radius: 90
)

Triangle.new(
  color: 'orange',
  x1:0, y1: 0,
  x2:40, y2: 0,
  x3:0, y3: 40,
)

sprite = Sprite.new(
  'character.png',
  x: 100,
  y: 380,
  clip_width: 60,
  animations: { fly: 1..3 }
)

sound = Sound.new('jump.ogg')

music = Music.new("background_music.ogg", loop: true)
music.play

Text.new(
  'My Ruby 2D Game',
  x: 180,
  y: 10,
  size: 42,
  color: 'black'
)

on :key_held do |event|
  sprite.play(animation: :fly)

  case event.key
  when 'up'
    sprite.y -= 5
  when 'down'
    sprite.y += 5
  when 'left'
    sprite.x -= 5
  when 'right'
    sprite.x += 5
  end
end

on :key_up do
  sprite.stop
end

on :key_down do
  sound.play
end

show