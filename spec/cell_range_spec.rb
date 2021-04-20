# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'cell_range'

RSpec.describe 'CellRange' do
  context 'created via new()' do
    let(:row_first) { 2 }
    let(:col_first) { 3 }
    let(:row_last) { 6 }
    let(:col_last) { 7 }
    before(:example) do
      @range = CellRange.new(row_first, col_first, row_last, col_last)
    end
    it 'returns row_first' do
      expect(@range.row_first).to eq row_first
    end
    it 'returns col_first' do
      expect(@range.col_first).to eq col_first
    end
    it 'returns row_last' do
      expect(@range.row_last).to eq row_last
    end
    it 'returns col_last' do
      expect(@range.col_last).to eq col_last
    end
    it 'returns the number of rows' do
      expect(@range.row_count).to eq(row_last - row_first + 1)
    end
    it 'returns the number of columns' do
      expect(@range.col_count).to eq(col_last - col_first + 1)
    end
    context 'with an equivalent cell range' do
      before(:example) do
        @copy = CellRange.new(row_first, col_first, row_last, col_last)
      end
      it 'declares the two ranges eql' do
        expect(@range.eql?(@copy)).to be true
      end
      it 'declares the two ranges ==' do
        expect(@range == @copy).to be true
      end
    end
    context 'with a different cell range' do
      before(:example) do
        @copy = CellRange.new(row_first, col_first + 1, row_last, col_last)
      end
      it 'declares the two ranges not eql' do
        expect(@range.eql?(@copy)).to be false
      end
      it 'declares the two ranges not ==' do
        expect(@range == @copy).to be false
      end
    end
  end

  context 'created via new_from_cells()' do
    let(:row_first) { 1 }
    let(:col_first) { 1 }
    let(:row_last) { 2 }
    let(:col_last) { 2 }
    let(:cell1) { double('cell1') }
    let(:cell2) { double('cell2') }
    before(:each) do
      allow(cell1).to receive(:row).and_return(row_first)
      allow(cell1).to receive(:col).and_return(col_first)
      allow(cell2).to receive(:row).and_return(row_last)
      allow(cell2).to receive(:col).and_return(col_last)
      @range = CellRange.new_from_cells(cell1, cell2)
    end
    it 'returns row_first' do
      expect(@range.row_first).to eq row_first
    end
    it 'returns col_first' do
      expect(@range.col_first).to eq col_first
    end
    it 'returns row_last' do
      expect(@range.row_last).to eq row_last
    end
    it 'returns col_last' do
      expect(@range.col_last).to eq col_last
    end
    it 'returns the number of rows' do
      expect(@range.row_count).to eq(row_last - row_first + 1)
    end
    it 'returns the number of columns' do
      expect(@range.col_count).to eq(col_last - col_first + 1)
    end
    it 'yields a new cell for each element of the range' do
      rc = @range.row_count
      cc = @range.col_count
      expect { |probe| @range.each(&probe) }.to \
        yield_control.exactly(rc * cc).times
    end
    it 'yields cells incrementing column first' do
      # #map() works because CellRange includes the Enumerable mixin.
      list = @range.map { |c| [c.row, c.col] }
      expect(list).to eq [[1, 1], [1, 2], [2, 1], [2, 2]]
    end
  end
end
