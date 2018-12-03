#
#
class BoardPrint

  def BoardPrint.render(board)
    row_format = "| %1s | %1s | %1s |\n"
    printf("\n")
    printf(row_format, board.xy(1, 1), board.xy(2, 1), board.xy(3, 1))
    printf(row_format, board.xy(1, 2), board.xy(2, 2), board.xy(3, 2))
    printf(row_format, board.xy(1, 3), board.xy(2, 3), board.xy(3, 3))
  end
end