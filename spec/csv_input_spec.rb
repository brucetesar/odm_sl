# frozen_string_literal: true

# Author: Bruce Tesar

require_relative '../lib/odl/resolver'
require 'csv_input'

RSpec.describe 'CsvInput' do
  fixture_dir = File.join(ODL::SPEC_DIR, 'fixtures')

  context 'when created with a valid CSV file' do
    before do
      infile = File.join(fixture_dir, 'erc_input1.csv')
      @csv_input = CsvInput.new(infile)
    end

    it 'returns an array of column headers' do
      expect(@csv_input.headers).to eq(%w[ERC_Label Con1 Con2 Con3])
    end

    it 'returns an array of arrays of the data' do
      expect(@csv_input.data).to eq([%w[E1 W L W], %w[E2 e W L]])
    end
  end

  context 'when created with a file containing numeric data' do
    before do
      infile = File.join(fixture_dir, 'cand_input1.csv')
      @csv_input = CsvInput.new(infile)
    end

    it 'returns a data array of all strings' do
      expect(@csv_input.data[0]).to all be_a_kind_of(String)
    end

    it 'returns an array of arrays of the data' do
      expect(@csv_input.data).to eq([%w[in1 out11 0 3 2]])
    end
  end
end
