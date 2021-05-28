# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'rspec'
require 'output'

RSpec.describe Output do
  def allow_main_stress(syllable)
    allow(syllable).to receive(:unstressed?).and_return(false)
    allow(syllable).to receive(:main_stress?).and_return(true)
    allow(syllable).to receive(:stress_unset?).and_return(false)
  end

  def allow_unstressed(syllable)
    allow(syllable).to receive(:unstressed?).and_return(true)
    allow(syllable).to receive(:main_stress?).and_return(false)
    allow(syllable).to receive(:stress_unset?).and_return(false)
  end

  def allow_unset(syllable)
    allow(syllable).to receive(:unstressed?).and_return(false)
    allow(syllable).to receive(:main_stress?).and_return(false)
    allow(syllable).to receive(:stress_unset?).and_return(true)
  end

  let(:syl1_stress) { double('syl1_stress') }
  let(:syl2_nostress) { double('syl2_nostress') }
  let(:syl3_unset) { double('syl3_unset') }
  let(:mword) { double('mword') }

  before do
    # stress-related behavior
    allow_main_stress(syl1_stress)
    allow_unstressed(syl2_nostress)
    allow_unset(syl3_unset)
    # to_s behavior
    allow(syl1_stress).to receive(:to_s).and_return('syl1')
    allow(syl2_nostress).to receive(:to_s).and_return('syl2')
    allow(syl3_unset).to receive(:to_s).and_return('syl3')
    @output = described_class.new
  end

  context 'with one stressed syllable' do
    before do
      @output << syl1_stress
    end

    it 'has a main stress' do
      expect(@output.main_stress?).to be true
    end

    it 'has a nil morphword' do
      expect(@output.morphword).to be_nil
    end

    it 'returns string "syl1"' do
      expect(@output.to_s).to eq 'syl1'
    end

    context 'when morphword is set' do
      before do
        @output.morphword = mword
      end

      it 'returns the morphword' do
        expect(@output.morphword).to eq mword
      end
    end
  end

  context 'with one unstressed syllable' do
    before do
      @output << syl2_nostress
    end

    it 'does not have a main stress' do
      expect(@output.main_stress?).to be false
    end

    it 'returns the string "syl2"' do
      expect(@output.to_s).to eq 'syl2'
    end

    context 'when a stressed syllable is added' do
      before do
        @output << syl1_stress
      end

      it 'has a main stress' do
        expect(@output.main_stress?).to be true
      end

      it 'returns the string "syl2syl1"' do
        expect(@output.to_s).to eq 'syl2syl1'
      end
    end
  end

  context 'with one unset syllable' do
    before do
      @output << syl3_unset
    end

    it 'does not have a main stress' do
      expect(@output.main_stress?).to be false
    end
  end

  context 'with one stress and one unstressed syllable' do
    before do
      @output << syl1_stress << syl2_nostress
    end

    it 'has a main stress' do
      expect(@output.main_stress?).to be true
    end

    it 'returns the string "syl1syl2"' do
      expect(@output.to_s).to eq 'syl1syl2'
    end
  end

  # equality methods

  context 'with an other output with the same elements and same morphword' do
    before do
      @output << syl1_stress << syl2_nostress << syl3_unset
      @output.morphword = mword
      @other = described_class.new << syl1_stress << syl2_nostress << syl3_unset
      @other.morphword = mword
    end

    it 'is #== to other' do
      expect(@output == @other).to be true
    end

    it 'is eql? to other' do
      expect(@output.eql?(@other)).to be true
    end
  end

  context 'with an other with differently ordered elements' do
    before do
      @output << syl1_stress << syl2_nostress << syl3_unset
      @output.morphword = mword
      @other = described_class.new << syl3_unset << syl1_stress << syl2_nostress
      @other.morphword = mword
    end

    it 'is not #== to other' do
      expect(@output == @other).to be false
    end

    it 'is not eql? to other' do
      expect(@output.eql?(@other)).to be false
    end
  end

  context 'with an other with fewer same-ordered elements' do
    before do
      @output << syl1_stress << syl2_nostress << syl3_unset
      @output.morphword = mword
      @other = described_class.new << syl1_stress << syl2_nostress
      @other.morphword = mword
    end

    it 'is not #== to other' do
      expect(@output == @other).to be false
    end

    it 'is not eql? to other' do
      expect(@output.eql?(@other)).to be false
    end
  end

  # dup()

  context 'with a duplicate' do
    let(:mword_dup) { double('mword_dup') }
    let(:syl1_dup) { double('syl1_dup') }
    let(:syl2_dup) { double('syl2_dup') }

    before do
      @output << syl1_stress << syl2_nostress
      @output.morphword = mword
      allow(mword).to receive(:dup).and_return(mword_dup)
      allow(mword).to receive(:==).with(mword_dup).and_return(true)
      allow(syl1_stress).to receive(:dup).and_return(syl1_dup)
      allow(syl1_stress).to receive(:==).with(syl1_dup).and_return(true)
      allow(syl2_nostress).to receive(:dup).and_return(syl2_dup)
      allow(syl2_nostress).to receive(:==).with(syl2_dup).and_return(true)
      allow_main_stress(syl1_dup)
      allow_unstressed(syl2_dup)
      @dup = @output.dup
    end

    it 'has an equivalent morphword to the duplicate' do
      expect(@output.morphword).to eq @dup.morphword
    end

    it 'does not have the same morphword object as the duplicate' do
      expect(@output.morphword).not_to equal @dup.morphword
    end

    it 'is equivalent to the duplicate' do
      expect(@output).to eq @dup
    end

    it 'is not the same object as the duplicate' do
      expect(@output).not_to equal @dup
    end

    it 'has a first syllable equivalent to the duplicate first syllable' do
      expect(@output.first).to eq @dup.first
    end

    it 'first syllable is not the same object as for the duplicate' do
      expect(@output.first).not_to equal @dup.first
    end

    it 'has main stress' do
      expect(@output.main_stress?).to be true
    end

    it 'the duplicate has main stress' do
      expect(@dup.main_stress?).to be true
    end
  end

  # shallow_copy()

  context 'with a shallow copy' do
    before do
      @output << syl1_stress << syl2_nostress
      @output.morphword = mword
      @copy = @output.shallow_copy
    end

    it 'has an equivalent morphword to the copy' do
      expect(@output.morphword).to eq @copy.morphword
    end

    it 'has the same morphword object as the copy' do
      expect(@output.morphword).to equal @copy.morphword
    end

    it 'is equivalent to the copy' do
      expect(@output).to eq @copy
    end

    it 'is not the same object as the copy' do
      expect(@output).not_to equal @copy
    end

    it 'has a first syllable equivalent to the copy first syllable' do
      expect(@output.first).to eq @copy.first
    end

    it 'first syllable is the same object as the copy first syllable' do
      expect(@output.first).to equal @copy.first
    end

    it 'has main stress' do
      expect(@output.main_stress?).to be true
    end

    it 'the copy has main stress' do
      expect(@copy.main_stress?).to be true
    end
  end

  # Methods like << often return self, so that calls can be stacked.
  # Make sure that Output#<< follows that expected behavior.
  context 'when Output#<< is called' do
    before do
      @output = described_class.new
      @result = (@output << 's1')
    end

    it 'returns an object of class Output' do
      expect(@result.class).to eq described_class
    end

    it 'returns the callee' do
      expect(@result).to equal @output
    end
  end
end
