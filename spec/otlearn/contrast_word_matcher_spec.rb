# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/contrast_word_matcher'

RSpec.describe OTLearn::ContrastWordMatcher do
  let(:m1) { double('morph1') }
  let(:m2) { double('morph2') }
  let(:m3) { double('morph3') }
  let(:m4) { double('morph4') }

  before do
    @matcher = described_class.new
  end

  context 'when target_mw and other_mw have different sizes' do
    before do
      ref_mw = [m1, m2, m3]
      other_mw = [m1, m4]
      @target_morph = m2
      @contrast_morph = @matcher.match(ref_mw, @target_morph, other_mw)
    end

    it 'returns nil' do
      expect(@contrast_morph).to be_nil
    end
  end

  context 'when other differs only in the target morpheme' do
    before do
      ref_mw = [m1, m2, m3]
      other_mw = [m1, m4, m3]
      @target_morph = m2
      @contrast_morph = @matcher.match(ref_mw, @target_morph, other_mw)
    end

    it 'returns the contrast morpheme' do
      expect(@contrast_morph).to eq m4
    end
  end

  context 'when other does not differ in the target morpheme' do
    before do
      ref_mw = [m1, m2, m3]
      other_mw = [m1, m2, m4]
      @target_morph = m2
      @contrast_morph = @matcher.match(ref_mw, @target_morph, other_mw)
    end

    it 'returns nil' do
      expect(@contrast_morph).to be_nil
    end
  end

  context 'when other differs in the target morpheme and another' do
    before do
      ref_mw = [m2, m1]
      other_mw = [m4, m3]
      @target_morph = m2
      @contrast_morph = @matcher.match(ref_mw, @target_morph, other_mw)
    end

    it 'returns nil' do
      expect(@contrast_morph).to be_nil
    end
  end

  context 'when reference and other are contrasting monomorphemic words' do
    before do
      ref_mw = [m3]
      other_mw = [m4]
      @target_morph = m3
      @contrast_morph = @matcher.match(ref_mw, @target_morph, other_mw)
    end

    it 'returns the contrasting morpheme' do
      expect(@contrast_morph).to eq m4
    end
  end

  context 'when reference does not contain the target morpheme' do
    before do
      ref_mw = [m1, m3]
      other_mw = [m1, m4]
      @target_morph = m4
      @contrast_morph = @matcher.match(ref_mw, @target_morph, other_mw)
    end

    it 'returns nil' do
      expect(@contrast_morph).to be_nil
    end
  end

  context 'when reference contains multiple occurrences of the target' \
          ' morpheme' do
    before do
      @ref_mw = [m1, m3, m1]
      @other_mw = [m4, m3, m2]
      @target_morph = m1
    end

    it 'raises a RuntimeError' do
      msg = 'ContrastWordMatcher#match: target word cannot appear multiple'\
            ' times'
      expect { @matcher.match(@ref_mw, @target_morph, @other_mw) }.to\
        raise_error(RuntimeError, msg)
    end
  end
end
