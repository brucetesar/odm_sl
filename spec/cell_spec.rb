# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'cell'

RSpec.describe 'Cell' do
  before(:example) do
    @cell = Cell.new(2, 3)
  end

  it 'returns its row' do
    expect(@cell.row).to eq 2
  end
  it 'returns its column' do
    expect(@cell.col).to eq 3
  end
  it 'is == a cell with the same row/col' do
    expect(@cell == Cell.new(2, 3)).to be true
  end
  it 'is eql? a cell with the same row/col' do
    expect(@cell.eql?(Cell.new(2, 3))).to be true
  end
  it 'is not == a cell with different row/col' do
    expect(@cell == Cell.new(2, 4)).to be false
  end
  it 'is not eql? a cell with different row/col' do
    expect(@cell.eql?(Cell.new(2, 4))).to be false
  end
end
