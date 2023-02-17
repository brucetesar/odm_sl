# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'

RSpec.describe Sheet do
  context 'when newly created' do
    before do
      @sheet = described_class.new
    end

    it 'contains 1 row' do
      expect(@sheet.row_count).to eq(1)
    end

    it 'contains 1 column' do
      expect(@sheet.col_count).to eq(1)
    end

    it 'contains one empty cell' do
      expect(@sheet[1, 1]).to be_nil
    end
    # return nil for a cell outside the current sheet range

    it 'returns nil for cell(2,3)' do
      cell = instance_double(Cell, row: 2, col: 3)
      expect(@sheet.get_cell(cell)).to be_nil
    end

    it 'contains all nil values' do
      expect(@sheet.all_nil?).to be true
    end

    it 'has nil in cell(1,1)' do
      cell = instance_double(Cell, row: 1, col: 1)
      expect(@sheet.get_cell(cell)).to be_nil
    end

    context "with [3,2] = 'stuff'" do
      before do
        @sheet[3, 2] = 'stuff'
      end

      it 'contains 3 rows' do
        expect(@sheet.row_count).to eq(3)
      end

      it 'contains 2 columns' do
        expect(@sheet.col_count).to eq(2)
      end

      it 'has nil in [1,1]' do
        expect(@sheet[1, 1]).to be_nil
      end

      it 'does not have nil in [3,2]' do
        expect(@sheet[3, 2]).not_to be_nil
      end

      it "has value 'stuff' in [3,2]" do
        expect(@sheet[3, 2]).to eq('stuff')
      end

      it 'does not contain all nil values' do
        expect(@sheet.all_nil?).to be false
      end

      it "has value 'stuff' in cell(3,2)" do
        cell = instance_double(Cell, row: 3, col: 2)
        expect(@sheet.get_cell(cell)).to eq('stuff')
      end

      it 'has nil in cell(1,1)' do
        cell = instance_double(Cell, row: 1, col: 1)
        expect(@sheet.get_cell(cell)).to be_nil
      end
    end

    context "with value 'stuff' put to cell (3,2)" do
      before do
        @cell = instance_double(Cell, row: 3, col: 2)
        @sheet.put_cell(@cell, 'stuff')
      end

      it 'contains 3 rows' do
        expect(@sheet.row_count).to eq(3)
      end

      it 'contains 2 columns' do
        expect(@sheet.col_count).to eq(2)
      end

      it 'has nil in [1,1]' do
        expect(@sheet[1, 1]).to be_nil
      end

      it 'does not have nil in [3,2]' do
        expect(@sheet[3, 2]).not_to be_nil
      end

      it "has value 'stuff' in [3,2]" do
        expect(@sheet[3, 2]).to eq('stuff')
      end

      it 'does not contain all nil values' do
        expect(@sheet.all_nil?).to be false
      end
    end
  end

  context 'when created from a 3x3 array with entry values 1..9' do
    before do
      @ar = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
      @sheet = described_class.new_from_a(@ar)
    end

    it 'has 3 rows' do
      expect(@sheet.row_count).to eq(3)
    end

    it 'has 3 columns' do
      expect(@sheet.col_count).to eq(3)
    end

    it 'has value 1 in [1,1]' do
      expect(@sheet[1, 1]).to eq 1
    end

    it 'has value 6 in [2,3]' do
      expect(@sheet[2, 3]).to eq 6
    end

    it 'returns an array equivalent to the original' do
      expect(@sheet.to_a).to eq @ar
    end
  end

  # *************************************************
  # Specs for convenience methods adding to the sheet
  # *************************************************

  context 'with 3 rows' do
    before do
      @sheet = described_class.new_from_a([[1], [2], [3]])
    end

    it 'has 3 rows' do
      expect(@sheet.row_count).to eq 3
    end

    context 'when an empty row is added' do
      before do
        @sheet.add_empty_row
      end

      it 'has 4 rows' do
        expect(@sheet.row_count).to eq 4
      end

      it 'has an empty 4th row' do
        all_nil = (1..@sheet.col_count).all? { |col| @sheet[4, col].nil? }
        expect(all_nil).to be true
      end

      it 'does not have an empty 3rd row' do
        all_nil = (1..@sheet.col_count).all? { |col| @sheet[3, col].nil? }
        expect(all_nil).to be false
      end
    end

    context 'when a 2-row inner sheet is appended' do
      let(:inner_sheet) { described_class.new_from_a([[10], [11]]) }

      before do
        @sheet.append(inner_sheet)
      end

      it 'has 5 rows' do
        expect(@sheet.row_count).to eq 5
      end

      it 'has the upper inner sheet in row 4' do
        expect(@sheet[4, 1]).to eq 10
      end

      it 'has the lower inner sheet in row 5' do
        expect(@sheet[5, 1]).to eq 11
      end
    end

    context 'when a 2-row inner sheet is appended starting column 3' do
      let(:inner_sheet) { described_class.new_from_a([[10], [11]]) }

      before do
        @sheet.append(inner_sheet, start_col: 3)
      end

      it 'has 5 rows' do
        expect(@sheet.row_count).to eq 5
      end

      it 'has the upper inner sheet in row 4, column 3' do
        expect(@sheet[4, 3]).to eq 10
      end

      it 'has the lower inner sheet in row 5, column 3' do
        expect(@sheet[5, 3]).to eq 11
      end

      it 'has empty cells prior to column 3 in rows 4 and 5' do
        empty_r4 = (1..2).all? { |col| @sheet[4, col].nil? }
        empty_r5 = (1..2).all? { |col| @sheet[5, col].nil? }
        all_empty = (empty_r4 && empty_r5)
        expect(all_empty).to be true
      end
    end
  end

  # ************************************************
  # Specs for conversion between nil and blank cells
  # ************************************************

  context 'with [[1,nil],[nil,4]], when nil converted to blank' do
    before do
      @sheet = described_class.new
      @sheet[1, 1] = 1
      @sheet[2, 2] = 4
      @sheet.nil_to_blank!
    end

    it 'has 2 rows' do
      expect(@sheet.row_count).to eq 2
    end

    it 'has 2 columns' do
      expect(@sheet.col_count).to eq 2
    end

    it 'has sheet[1,1] = 1' do
      expect(@sheet[1, 1]).to eq 1
    end

    it "has sheet[1,2] = ' '" do
      expect(@sheet[1, 2]).to eq ' '
    end

    it "has sheet[2,1] = ' '" do
      expect(@sheet[2, 1]).to eq ' '
    end

    it 'has sheet[2,2] = 4' do
      expect(@sheet[2, 2]).to eq 4
    end
  end

  # ********************************************************
  # Specs for cell translation into a new frame of reference
  # ********************************************************

  context 'with Cell (4,1)' do
    before do
      @cell = instance_double(Cell, row: 4, col: 1)
    end

    it 'has a cell translation, with respect to (5,5), of (8,5)' do
      ref_cell = instance_double(Cell, row: 5, col: 5)
      expect(described_class.translate_cell(@cell, ref_cell)).to \
        eq(Cell.new(8, 5))
    end

    it 'has a cell translation, with respect to (1,1), of (4,1)' do
      ref_cell = instance_double(Cell, row: 1, col: 1)
      expect(described_class.translate_cell(@cell, ref_cell)).to \
        eq(Cell.new(4, 1))
    end

    it 'has a cell translation, with respect to (6,3), of (9,3)' do
      ref_cell = instance_double(Cell, row: 6, col: 3)
      expect(described_class.translate_cell(@cell, ref_cell)).to \
        eq(Cell.new(9, 3))
    end
  end

  context 'with content [[1,2],[3,4]]' do
    before do
      @sheet = described_class.new_from_a([[1, 2], [3, 4]])
    end

    context 'when sheet [[11,12],[13,14]] is put with reference cell (2,1)' do
      before do
        @ref_cell = instance_double(Cell, row: 2, col: 1)
        @source_sheet = described_class.new_from_a([[11, 12], [13, 14]])
        @sheet.put_range_to_cell(@ref_cell, @source_sheet)
      end

      it 'has value 11 at [2,1]' do
        expect(@sheet[2, 1]).to eq(11)
      end

      it 'has value 12 at [2,2]' do
        expect(@sheet[2, 2]).to eq(12)
      end

      it 'has value 13 at [3,1]' do
        expect(@sheet[3, 1]).to eq(13)
      end

      it 'has value 14 at [3,2]' do
        expect(@sheet[3, 2]).to eq(14)
      end
    end

    context 'with sheet.put_range(2,1,[[11,12],[13,14]])' do
      before do
        @source_sheet = described_class.new_from_a([[11, 12], [13, 14]])
        @sheet.put_range(2, 1, @source_sheet)
      end

      it 'has 3 rows' do
        expect(@sheet.row_count).to eq 3
      end

      it 'has 2 columns' do
        expect(@sheet.col_count).to eq 2
      end

      it 'has value 11 at [2,1]' do
        expect(@sheet[2, 1]).to eq(11)
      end

      it 'has value 12 at [2,2]' do
        expect(@sheet[2, 2]).to eq(12)
      end

      it 'has value 13 at [3,1]' do
        expect(@sheet[3, 1]).to eq(13)
      end

      it 'has value 14 at [3,2]' do
        expect(@sheet[3, 2]).to eq(14)
      end
    end
  end

  # *********************************************************************
  # Specs for cell retrieval relative to a non-origin frame of reference.
  # *********************************************************************

  context 'with Cell (7,4)' do
    before do
      @cell = instance_double(Cell, row: 7, col: 4)
    end

    it 'is located, in reference frame starting (1,1), at (7,4)' do
      ref_cell = instance_double(Cell, row: 1, col: 1)
      expect(described_class.relative_to_cell(@cell, ref_cell)).to \
        eq(Cell.new(7, 4))
    end

    it 'is located, in reference frame starting (2,3), at (6,2)' do
      ref_cell = instance_double(Cell, row: 2, col: 3)
      expect(described_class.relative_to_cell(@cell, ref_cell)).to \
        eq(Cell.new(6, 2))
    end
  end

  context 'with content [[1,2,3],[4,5,6],[7,8,9]]' do
    before do
      @sheet = described_class.new_from_a([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
    end

    context 'when a sheet of range (2,3,2,3) is gotten' do
      before do
        @range = CellRange.new(2, 3, 2, 3)
        @new_sheet = @sheet.get_range(@range)
      end

      it 'has one row' do
        expect(@new_sheet.row_count).to eq(1)
      end

      it 'has one column' do
        expect(@new_sheet.col_count).to eq(1)
      end

      it 'has value 6 at position (1,1)' do
        expect(@new_sheet[1, 1]).to eq(6)
      end
    end

    context 'when a sheet of range (2,1,3,2) is gotten' do
      before do
        @range = CellRange.new(2, 1, 3, 2)
        @new_sheet = @sheet.get_range(@range)
      end

      it 'has two rows' do
        expect(@new_sheet.row_count).to eq(2)
      end

      it 'has two columns' do
        expect(@new_sheet.col_count).to eq(2)
      end

      it 'has value 4 at position (1,1)' do
        expect(@new_sheet[1, 1]).to eq(4)
      end

      it 'has value 5 at position (1,2)' do
        expect(@new_sheet[1, 2]).to eq(5)
      end

      it 'has value 7 at position (2,1)' do
        expect(@new_sheet[2, 1]).to eq(7)
      end

      it 'has value 8 at position (2,2)' do
        expect(@new_sheet[2, 2]).to eq(8)
      end
    end
  end
end
