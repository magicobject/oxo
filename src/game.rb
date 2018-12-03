require_relative 'board'
require_relative 'board_print'

board = Board.new

def read_square(board)
  print "\nEnter your move: "
  square = gets.to_i

  if square < 0 || square > 8
    print "No such square\n"
    return read_square board
  end

  if board.occupied?(square)
    print "That square is already taken\n"
    return read_square board
  end

  square
end

BoardPrint.render(board)

until board.game_over? do
  # Players move
  square = read_square board
  board = board.move(:O, square)
  BoardPrint.render(board)
  break if board.game_over?

  # Engine move
  square = board.calculate_computers_move
  board = board.move(:X, square)
  BoardPrint.render(board)
end


#BoardPrint.render(board)
print "Game over\n"





