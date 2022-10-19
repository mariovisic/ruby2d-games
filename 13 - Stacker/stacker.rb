require 'ruby2d'

GRID_SIZE = 40
WIDTH = 7
HEIGHT = 20
GRID_COLOR = Color.new('#222222')
BLOCK_COLOR = Color.new(['orange', 'yellow', 'green'].sample)

set width: WIDTH * GRID_SIZE
set height: HEIGHT * GRID_SIZE

(0..Window.width).step(GRID_SIZE).each do |x|
  Line.new(x1: x, x2: x, y1: 0, y2: Window.height, width: 2, color: GRID_COLOR, z: 1)
end

(0..Window.height).step(GRID_SIZE).each do |y|
  Line.new(y1: y, y2: y, x1: 0, x2: Window.width, width: 2, color: GRID_COLOR, z: 1)
end


current_line = HEIGHT - 1
current_direction = :right
speed = 4
score = 0

frozen_squares = {}
active_squares = (0..4).map do |index|
  Square.new(
    x: GRID_SIZE * index,
    y: GRID_SIZE * current_line,
    size: GRID_SIZE,
    color: BLOCK_COLOR
  )
end

update do
  if active_squares.empty?
    Text.new("Game over!", size: 30, x: 60, y: 80, z: 2)
    Text.new("Your score: #{score}", size: 30, x: 40, y: 120, z: 2)
  else
    if Window.frames % (60 / speed) == 0
      case current_direction
      when :right
        active_squares.each { |square| square.x += GRID_SIZE }
        if active_squares.last.x + active_squares.last.width >= Window.width
          current_direction = :left
        end
      when :left
        active_squares.each { |square| square.x -= GRID_SIZE }
        if active_squares.first.x <= 0
          current_direction = :right
        end
      end
    end
  end
end

on :key_down do
  current_line -= 1
  speed += 1

  active_squares.each do |active_square|
    if current_line == HEIGHT - 2 || frozen_squares.has_key?("#{active_square.x},#{active_square.y + GRID_SIZE}")
      frozen_squares["#{active_square.x},#{active_square.y}"] = Square.new(
        x: active_square.x,
        y: active_square.y,
        color: BLOCK_COLOR,
        size: GRID_SIZE
      )
    end
  end

  active_squares.each(&:remove)
  active_squares = []

  (0..WIDTH).each do |index|
    x = GRID_SIZE * index
    y = GRID_SIZE * current_line

    if frozen_squares.has_key?("#{x},#{y + GRID_SIZE}")
      active_squares.push(Square.new(
        x: x,
        y: y,
        color: BLOCK_COLOR,
        size: GRID_SIZE
      ))
    end
  end

  score = frozen_squares.size
end


show