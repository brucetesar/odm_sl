# frozen_string_literal: true

# Author: Bruce Tesar

# An address of a cell in a two-dimensional sheet. IMPORTANT: this is
# *not* a complete functioning cell, only a coordinate-based address
# of a cell, containing row and column values.
class Cell
  # The row value for the cell
  attr_accessor :row

  # The column value for the cell
  attr_accessor :col

  # Returns a Cell with _row_ and _column_.
  # :call-seq:
  #   new(row, column) -> cell
  def initialize(row, column)
    @row = row
    @col = column
  end

  # Returns true if _other_ has the same row and column indices
  # as self. Returns false otherwise.
  def eql?(other)
    return false unless row == other.row
    return false unless col == other.col

    true
  end

  # Returns true if _other_ has the same row and column indices
  # as self. Returns false otherwise.
  def ==(other)
    eql?(other)
  end
end
