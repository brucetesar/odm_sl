# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'odl/competition_generator'

RSpec.describe ODL::CompetitionGenerator do
  let(:system) { double('system') }
  let(:lexicon) { double('lexicon') }

  before do
    @generator = described_class.new(system)
  end

  context 'with one morphword' do
    let(:mw1) { double('morphword 1') }
    let(:in1) { double('input 1') }

    before do
      allow(system).to receive(:input_from_morphword).with(mw1, lexicon)\
                                                     .and_return(in1)
      allow(system).to receive(:gen).with(in1).and_return(:comp1)
      @competitions = @generator.competitions([mw1], lexicon)
    end

    it 'generates one competition' do
      expect(@competitions).to eq [:comp1]
    end
  end

  context 'with two morphwords' do
    let(:mw1) { double('morphword 1') }
    let(:mw2) { double('morphword 2') }
    let(:in1) { double('input 1') }
    let(:in2) { double('input 2') }

    before do
      allow(system).to receive(:input_from_morphword).with(mw1, lexicon)\
                                                     .and_return(in1)
      allow(system).to receive(:input_from_morphword).with(mw2, lexicon)\
                                                     .and_return(in2)
      allow(system).to receive(:gen).with(in1).and_return(:comp1)
      allow(system).to receive(:gen).with(in2).and_return(:comp2)
      @competitions = @generator.competitions([mw1, mw2], lexicon)
    end

    it 'generates two competitions' do
      expect(@competitions).to eq [:comp1, :comp2]
    end
  end
end
