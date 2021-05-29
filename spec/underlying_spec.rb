# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'underlying'

RSpec.describe Underlying do
  let(:s1) { double('s1') }
  let(:s2) { double('s2') }
  let(:s1_dup) { double('s1_dup') }
  let(:s2_dup) { double('s2_dup') }

  before do
    allow(s1).to receive(:to_s).and_return('s1')
    allow(s2).to receive(:to_s).and_return('s2')
    allow(s1).to receive(:dup).and_return(s1_dup)
    allow(s2).to receive(:dup).and_return(s2_dup)
    @uf = described_class.new
  end

  context 'when s1 and s2 are appended' do
    before do
      @uf << s1 << s2
    end

    it 'has first element s1' do
      expect(@uf[0]).to eq s1
    end

    it 'has second element s2' do
      expect(@uf[1]).to eq s2
    end

    it 'has string representation "s1s2"' do
      expect(@uf.to_s).to eq 's1s2'
    end
  end

  context 'with a duplicate' do
    before do
      @uf << s1 << s2
      @dup = @uf.dup
    end

    it 'is not the same object as the original' do
      expect(@dup).not_to equal @uf
    end

    it 'has as its first element a duplicate of the original first element' do
      expect(@dup[0]).to equal s1_dup
    end

    it 'has as its seond element a duplicate of the original second element' do
      expect(@dup[1]).to equal s2_dup
    end
  end

  # Methods like << often return self, so that calls can be stacked.
  # Make sure that Underlying#<< follows that expected behavior.
  context 'when Underlying#<< is called' do
    before do
      @result = (@uf << 's1')
    end

    it 'returns the callee' do
      expect(@result).to equal @uf
    end
  end
end
