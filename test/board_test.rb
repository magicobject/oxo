require 'test/unit'
require_relative '../src/board'
require_relative '../src/board_print'

class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @board = Board.new
  end

  def test_board_offsets_work
    piece = :Fred
    board2 = @board.move(piece, 5);

    assert_equal(piece, board2.xy(3, 2))
    assert_not_equal(piece, @board.xy(3, 2))
  end

  def test_move_produces_a_different_board
    new_board = @board.move :X, 7
    assert_not_equal(new_board, @board)
  end

  def test_overwriting_an_occupied_square_fails
    begin
      @board.move(:O, 7).move(:X, 7)
      fail 'Expected exception was not thrown'
    rescue
      nil
    end
  end

  def test_invalid_move_fails
    begin
      @board.move(:O, 7).move(:O, 6)
      fail 'Expected exception was not thrown'
    rescue
      nil
    end
  end

  def test_full_board
    board = @board.move(:X, 0)
                .move(:O, 1)
                .move(:X, 2)
                .move(:O, 3)
                .move(:X, 4)
                .move(:O, 5)
                .move(:X, 7)
                .move(:O, 6)
    assert_false(board.full?)

    board = board.move(:X, 8)
    assert_true(board.full?)
  end

  def test_empty_board_does_not_win
    assert_false(@board.win?)
  end

  def test_win_1
    board = @board.move(:X, 0)
                .move(:O, 3)
                .move(:X, 1)
                .move(:O, 4)
                .move(:X, 2)
    assert_true(board.win?)
    assert_true(board.game_over?)
    assert_true(board.score == 10)
  end

  def test_win_2
    board = @board.move(:X, 0)
                .move(:O, 1)
                .move(:X, 2)
                .move(:O, 4)
                .move(:X, 5)
                .move(:O, 3)
                .move(:X, 6)
                .move(:O, 7)
    assert_true(board.win?)
    assert_true(board.score == -10)

    BoardPrint.render(board)
  end

  def test_drawn_position
    begin
      @board.move(:X, 0)
          .move(:O, 1)
          .move(:X, 2)
          .move(:O, 4)
          .move(:X, 5)
          .move(:O, 3)
          .move(:X, 7)
          .move(:O, 8)
          .move(:X, 6)
      fail('missed exception')
    rescue
      nil
    end
  end

  def test_game_not_over
    assert_false(@board.game_over?)
    assert_false(@board.move(:X, 1).game_over?)

    board = @board.move(:X, 0)
                .move(:O, 1)
                .move(:X, 2)
                .move(:O, 4)
                .move(:X, 5)
                .move(:O, 3)
                .move(:X, 7)
                .move(:O, 8)
                .move(:X, 6)
    assert_true(board.game_over?)
  end


  def test_double_win_throws_exception
    begin
      @board.move(:X, 0)
          .move(:O, 1)
          .move(:X, 2)
          .move(:O, 4)
          .move(:X, 5)
          .move(:O, 3)
          .move(:X, 6)
          .move(:O, 7)
          .move(:X, 8)
      fail('Missng exception')
    rescue
      nil
    end
  end

  def test_available_squares
    board = @board.
        move(:X, 4).
        move(:O, 6).
        move(:X, 0).
        move(:O, 8)
    assert_equal([0, 1, 2, 3, 4, 5, 6, 7, 8], @board.available_squares)
    assert_equal([1, 2, 3, 5, 7], board.available_squares)
  end

  def test_initial_score_is_zero
    assert_equal(0, @board.score)
  end

  def test_can_not_move_after_game_is_won
    board = @board.move(:X, 0).
                   move(:O, 3).
                   move(:X, 1).
                   move(:O, 4).
                   move(:X, 2)
    assert_true(board.win?)

    begin
      board2 = board.move(:O, 5)
      fail('Exception missed')
    rescue
      nil
    end
  end

  def test_next_boards_initially_returns_8_boards
    board = @board.move :O, 1
    boards = board.next_boards
    assert_equal(8, boards.length)
    board = board.move(:X, 4)
    assert_equal(7, board.next_boards.length)
  end

  def test_avoid_immediate_loss
    board = @board.move(:O, 1).move(:X, 5).move(:O, 2).
        move(:X, 7).move(:O, 8)

    x = board.available_squares.zip(board.next_scores).sort_by{ |key, value| value }.reverse.first.first
    assert_equal 0, x
  end
end