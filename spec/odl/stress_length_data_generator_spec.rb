# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'odl/stress_length_data_generator'
require 'morpheme'

RSpec.describe 'ODL::StressLengthDataGenerator' do
  let(:lexentry_generator) { double('lexentry_generator') }
  let(:competition_generator) { double('competition_generator') }
  let(:lexicon_class) { double('lexicon_class') }
  let(:lexicon) { double('lexicon') }
  let(:morphword_class) { double('morphword_class') }
  before(:example) do
    allow(lexicon_class).to receive(:new).and_return(lexicon)
    allow(lexicon).to receive(:add)
    @generator =
      ODL::StressLengthDataGenerator.new(lexentry_generator,
                                         competition_generator,
                                         lexicon_class: lexicon_class,
                                         morphword_class: morphword_class)
  end

  context 'when 1r1s competitions are generated' do
    let(:r1) { double('root1') }
    let(:r2) { double('root2') }
    let(:s1) { double('suffix1') }
    let(:s2) { double('suffix2') }
    let(:r1_le) { double('r1 lexical entry') }
    let(:r2_le) { double('r2 lexical entry') }
    let(:s1_le) { double('s1 lexical entry') }
    let(:s2_le) { double('s2 lexical entry') }
    let(:expected_comp_list) { double('expected_comp_list') }
    let(:mw1) { double('morphword1') }
    let(:mw2) { double('morphword2') }
    let(:mw3) { double('morphword3') }
    let(:mw4) { double('morphword4') }
    before(:example) do
      allow(lexentry_generator).to receive(:generate_morphemes)\
        .with(1, Morpheme::ROOT, 0).and_return([r1_le, r2_le])
      allow(lexentry_generator).to receive(:generate_morphemes)\
        .with(1, Morpheme::SUFFIX, 0).and_return([s1_le, s2_le])
      allow(r1_le).to receive(:morpheme).and_return(r1)
      allow(r2_le).to receive(:morpheme).and_return(r2)
      allow(s1_le).to receive(:morpheme).and_return(s1)
      allow(s2_le).to receive(:morpheme).and_return(s2)
      allow(morphword_class).to receive(:new).and_return(mw1, mw2, mw3, mw4)
      allow(mw1).to receive(:add).with(r1)
      allow(mw1).to receive(:add).with(s1)
      allow(mw2).to receive(:add).with(r1)
      allow(mw2).to receive(:add).with(s2)
      allow(mw3).to receive(:add).with(r2)
      allow(mw3).to receive(:add).with(s1)
      allow(mw4).to receive(:add).with(r2)
      allow(mw4).to receive(:add).with(s2)
      @words = [mw1, mw2, mw3, mw4]
      allow(competition_generator).to \
        receive(:competitions_from_morphwords)\
        .with(@words, lexicon).and_return(expected_comp_list)
      @comp_list = @generator.generate_competitions_1r1s
    end
    it 'adds r1_le to the lexicon' do
      expect(lexicon).to have_received(:add).with(r1_le)
    end
    it 'adds r2_le to the lexicon' do
      expect(lexicon).to have_received(:add).with(r2_le)
    end
    it 'adds s1_le to the lexicon' do
      expect(lexicon).to have_received(:add).with(s1_le)
    end
    it 'adds s2_le to the lexicon' do
      expect(lexicon).to have_received(:add).with(s2_le)
    end
    it 'adds r1 to morphword1' do
      expect(mw1).to have_received(:add).with(r1)
    end
    it 'adds s1 to morphword1' do
      expect(mw1).to have_received(:add).with(s1)
    end
    it 'adds r1 to morphword2' do
      expect(mw2).to have_received(:add).with(r1)
    end
    it 'adds s2 to morphword2' do
      expect(mw2).to have_received(:add).with(s2)
    end
    it 'adds r2 to morphword3' do
      expect(mw3).to have_received(:add).with(r2)
    end
    it 'adds s1 to morphword3' do
      expect(mw3).to have_received(:add).with(s1)
    end
    it 'adds r2 to morphword4' do
      expect(mw4).to have_received(:add).with(r2)
    end
    it 'adds s2 to morphword4' do
      expect(mw4).to have_received(:add).with(s2)
    end
    it 'returns a list of the competitions' do
      expect(@comp_list).to eq expected_comp_list
    end
  end
end
