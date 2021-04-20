# frozen_string_literal: true

# Author: Bruce Tesar

require 'cell'

# An address of a range of cells in a two-dimensional sheet.
# IMPORTANT: this is *not* a collection of actual cells, only
# a coordinate-based indication of a cell range, containing first row and
# column values, and last row and column values.
class CellRange
  include Enumerable

  # The first row of the range.
  attr_accessor :row_first

  # The first column of the range.
  attr_accessor :col_first

  # The last row of the range.
  attr_accessor :row_last

  # The last column of the range.
  attr_accessor :col_last

  # Returns a CellRange, given the first row/column values and
  # the last row/column values.
  # :call-seq:
  #   new(row_first, col_first, row_last, col_last) -> cell_range
  def initialize(row_first, col_first, row_last, col_last)
    @row_first = row_first
    @col_first = col_first
    @row_last = row_last
    @col_last = col_last
  end

  # Returns a CellRange that extends from _cell_first_ to _cell_last_.
  # :call-seq:
  #   new_from_cells(cell_first, cell_last) -> cell_range
  def self.new_from_cells(cell_first, cell_last)
    CellRange.new(cell_first.row, cell_first.col,
                  cell_last.row, cell_last.col)
  end

  # Returns true if _other_ defines exactly the same range (same first row,
  # same last row, same first column, same last column). Returns false
  # otherwise.
  def eql?(other)
    return false unless row_first.eql?(other.row_first)
    return false unless col_first.eql?(other.col_first)
    return false unless row_last.eql?(other.row_last)
    return false unless col_last.eql?(other.col_last)

    true
  end

  # Returns true if _other_ defines exactly the same range (same first row,
  # same last row, same first column, same last column). Returns false
  # otherwise.
  def ==(other)
    eql?(other)
  end

  # Returns the number of rows in the range.
  def row_count
    row_last - row_first + 1
  end

  # Returns the number of columns in the range.
  def col_count
    col_last - col_first + 1
  end

  # Yields a new Cell for each element in the cellrange, starting with the
  # first cell, and proceeding across each row, from first row to last,
  # ending at the last cell.
  def each # :yields: cell
    (@row_first..@row_last).each do |row|
      (@col_first..@col_last).each do |col|
        yield Cell.new(row, col)
      end
    end
  end
end
