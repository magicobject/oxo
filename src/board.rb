#
# OXO Board
#
class Board
  STATE_OK = :playable
  STATE_DRAWN = :drawn
  STATE_WON = :won

  def initialize(
      board = Array.new(9),
      last_piece_moved = :Unknown,
      computers_piece = :X
  )
    @board = board
    @last_piece_moved = last_piece_moved
    @computers_piece = computers_piece
    calculate_state

    raise 'Invalid move' unless valid
  end

  def occupied?(square)
    @board[square] != nil
  end

  # Needed by board_print - try moving there?
  # Map 2d space into 1d space
  # board[3,3] = board[8]
  # board[1,3] = board[2] etc
  # Return the piece at x,y measured with 1,1 at the top right corner
  # 3(offset_y - 1) + offset_x - 1 == 3*offset_y +offset_x - 4
  def xy(offset_x, offset_y)
    @board[3 * offset_y + offset_x - 4]
  end

  # Return an new Board with the requested move taken
  def move(piece, offset)
    raise 'Board already complete' if full?
    raise 'Square already occupied' unless @board[offset].nil?
    raise 'Game is over' unless @state == STATE_OK
    raise 'Not your turn' if piece == @last_piece_moved

    new_piece_array = @board.dup
    new_piece_array[offset] = piece
    Board.new(new_piece_array, piece, @computers_piece)
  end

  # Return the computer's move:
  # Recursively get the scores for the next move using the minimax algorithm,
  # then zip those to the array of possible moves so you get an array of
  # [ [move1, score1], [move2, score2], ...]
  # Now sort that array by scores and revers so they are in descending score order.
  # The first pair is the one we want and the square to put the controller's piece
  # is the first element in that array
  def calculate_computers_move
    available_squares.zip(next_scores).sort_by { |key, value| value }.reverse.first.first
  end

  def available_squares
    squares = []
    (0..8).each {|square| squares[square] = square unless @board[square]}
    squares.compact
  end

  def next_boards
    return [] if @state != STATE_OK

    piece = piece_to_move_next
    available_squares.collect {|square| move(piece, square)}
  end

  def full?
    x_count + o_count >= 9
  end

  def draw?
    full? && !win?
  end

  def win?
    return false if @board.compact.length < 5

    @board[0] && @board[0] == @board[1] && @board[0] == @board[2] ||
        @board[3] && @board[3] == @board[4] && @board[3] == @board[5] ||
        @board[6] && @board[6] == @board[7] && @board[6] == @board[8] ||
        @board[0] && @board[0] == @board[3] && @board[0] == @board[6] ||
        @board[1] && @board[1] == @board[4] && @board[1] == @board[7] ||
        @board[2] && @board[2] == @board[5] && @board[2] == @board[8] ||
        @board[0] && @board[0] == @board[4] && @board[0] == @board[8] ||
        @board[2] && @board[2] == @board[4] && @board[2] == @board[6]

    # You can get a double win so win count can be
    # greater than 1 with a legal winning position
  end

  def game_over?
    @state != STATE_OK
  end

  # This section is the game "engine" so needs to be factored out and injected as a strategy
  # next_scores is the entry point to the move calculator
  def next_scores
    if @last_piece_moved != @computers_piece
      max_scores # computers move
    else
      min_scores # players move
    end
  end

  def score
    return 0 if @state == STATE_OK
    return 0 if @state == STATE_DRAWN
    return 10 if @state == STATE_WON && @last_piece_moved == @computers_piece

    -10
  end

  #
  # if the state is not state_ok just return the win/draw score otherwise
  # dig down through the boards tree and get the max score recursively
  #
  def max_score
    return score if @state != STATE_OK

    next_boards.map(&:min_score).min
  end

  def min_score
    return score if @state != STATE_OK

    next_boards.map(&:max_score).max
  end

  # Return an array of my sub-boards max_scores
  def max_scores
    next_boards.map(&:max_score)
  end

  def min_scores
    next_boards.map(&:min_score)
  end

  private

  def calculate_state
    @state = STATE_OK
    if draw?
      @state = STATE_DRAWN
    elsif win?
      @state = STATE_WON
    end
  end

  # Count the number of squares containing a :X or :O
  def count(x_or_o)
    count = 0
    @board.each do |piece|
      piece == x_or_o && count += 1
    end
    count
  end

  def x_count
    count :X
  end

  def o_count
    count :O
  end

  def valid
    xc = x_count
    oc = o_count
    xc <= 5 && oc <= 5 && (xc - oc).abs <= 1
  end

  def piece_to_move_next
    return :O if @last_piece_moved == :X

    :X
  end
end