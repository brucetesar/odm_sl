# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'compare_stratum_ctie'
require 'erc'

RSpec.describe CompareStratumCtie do
  let(:erc) { instance_double(Erc, 'erc') }
  let(:con1) { double('constraint1') }
  let(:con2) { double('constraint2') }
  let(:con3) { double('constraint3') }

  before do
    @comparer = described_class.new
  end

  context 'when none of the stratum constraints have a preference' do
    before do
      stratum = [con1, con2, con3]
      allow(erc).to receive(:l?).and_return(false)
      allow(erc).to receive(:w?).and_return(false)
      @code = @comparer.more_harmonic(erc, stratum)
    end

    it 'returns :IDENT_VIOLATIONS' do
      expect(@code).to eq :IDENT_VIOLATIONS
    end
  end

  context 'when con2 prefers the winner, con1 and con3 no preference' do
    before do
      stratum = [con1, con2, con3]
      allow(erc).to receive(:l?).and_return(false)
      allow(erc).to receive(:w?).and_return(false)
      allow(erc).to receive(:w?).with(con2).and_return(true)
      @code = @comparer.more_harmonic(erc, stratum)
    end

    it 'returns :WINNER' do
      expect(@code).to eq :WINNER
    end
  end

  context 'when con1 prefers the loser, con2 and con3 no preference' do
    before do
      stratum = [con1, con2, con3]
      # NOTE: the allow statements for a method must be ordered from general
      # to specific; otherwise the later-declared general overrides.
      allow(erc).to receive(:l?).and_return(false)
      allow(erc).to receive(:l?).with(con1).and_return(true)
      allow(erc).to receive(:w?).and_return(false)
      @code = @comparer.more_harmonic(erc, stratum)
    end

    it 'returns :LOSER' do
      expect(@code).to eq :LOSER
    end
  end

  context 'when con1 prefers the winner, con2 and con3 prefer the loser' do
    before do
      stratum = [con1, con2, con3]
      allow(erc).to receive(:l?).with(con1).and_return(false)
      allow(erc).to receive(:l?).with(con2).and_return(true)
      allow(erc).to receive(:l?).with(con3).and_return(true)
      allow(erc).to receive(:w?).with(con1).and_return(true)
      allow(erc).to receive(:w?).with(con2).and_return(false)
      allow(erc).to receive(:w?).with(con3).and_return(false)
      @code = @comparer.more_harmonic(erc, stratum)
    end

    it 'returns :CONFLICT' do
      expect(@code).to eq :CONFLICT
    end
  end
end
