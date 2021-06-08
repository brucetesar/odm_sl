# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'word_values_package'

RSpec.describe WordValuesPackage do
  let(:word) { double('word') }
  let(:fv_pair1) { double('fv_pair1') }
  let(:values) { [fv_pair1] }

  before do
    @package = described_class.new(word, values)
  end

  it 'returns the word' do
    expect(@package.word).to eq word
  end

  it 'returns the list of feature-value pairs' do
    expect(@package.values).to contain_exactly(fv_pair1)
  end
end
