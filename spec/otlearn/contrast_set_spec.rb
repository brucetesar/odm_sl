# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/contrast_set'

RSpec.describe 'OTLearn::ContrastSet' do
  let(:word1_p) { double('word1_p') }
  let(:word2_p) { double('word2_p') }
  let(:word1) { double('word1') }
  let(:word2) { double('word2') }
  let(:in1) { double('in1') }
  let(:in2) { double('in2') }
  before(:example) do
    allow(word1_p).to receive(:dup).and_return(word1)
    allow(word2_p).to receive(:dup).and_return(word2)
    allow(word1).to receive(:input).and_return(in1)
    allow(word2).to receive(:input).and_return(in2)
    allow(in1).to receive(:to_gv).and_return('in1')
    allow(in2).to receive(:to_gv).and_return('in2')
  end

  context 'created with two words' do
    before(:example) do
      @cset = OTLearn::ContrastSet.new([word1_p, word2_p])
    end
    it 'contains duplicates of the two words' do
      expect(@cset).to contain_exactly(word1, word2)
    end
    it 'yields duplicates of the two words' do
      expect { |probe| @cset.each(&probe) }.to \
        yield_successive_args(word1, word2)
    end
    it 'returns a string appropriate for GraphViz' do
      expect(@cset.to_gv).to eq 'in1\nin2'
    end
  end
end
