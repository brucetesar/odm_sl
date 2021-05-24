# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'rspec'
require 'pas/syllable'
require 'feature'

RSpec.describe PAS::Syllable do
  let(:syllable) { described_class.new }

  it 'has an unset stress feature' do
    expect(syllable.stress_unset?).to be true
  end

  it 'has an unset length feature' do
    expect(syllable.length_unset?).to be true
  end

  it 'has morpheme ""' do
    expect(syllable.morpheme).to eq('')
  end

  it 'does not have main stress' do
    expect(syllable.main_stress?).to be false
  end

  it 'is not unstressed' do
    expect(syllable.unstressed?).to be false
  end

  it 'is not long' do
    expect(syllable.long?).to be false
  end

  it 'is not short' do
    expect(syllable.short?).to be false
  end

  it 'has string representation ??' do
    expect(syllable.to_s).to eq('??')
  end

  context 'when #each_feature is called' do
    before do
      @features = []
      syllable.each_feature { |f| @features << f }
    end

    it 'yields two features' do
      expect(@features.size).to eq(2)
    end

    it 'yields a length feature' do
      expect(@features[0].type).to eq(PAS::Length::LENGTH)
    end

    it 'yields a stress feature' do
      expect(@features[1].type).to eq(PAS::Stress::STRESS)
    end
  end

  context 'when set to unstressed and short' do
    before do
      syllable.set_unstressed.set_short
    end

    context 'when #get_feature returns a stress feature' do
      before do
        @s_feat = syllable.get_feature(PAS::Stress::STRESS)
      end

      it 'returns a stress feature that is of type STRESS' do
        expect(@s_feat.type).to eq(PAS::Stress::STRESS)
      end

      it 'returns a stress feature that is unstressed' do
        expect(@s_feat.unstressed?).to be true
      end
    end

    context 'when #get_feature returns a length feature' do
      before do
        @s_feat = syllable.get_feature(PAS::Length::LENGTH)
      end

      it 'returns a length feature that is of type LENGTH' do
        expect(@s_feat.type).to eq(PAS::Length::LENGTH)
      end

      it 'returns a length feature that is short' do
        expect(@s_feat.short?).to be true
      end
    end

    it 'get_feature raises an exception when given an invalid type' do
      expect { syllable.get_feature('not_a_type') }.to \
        raise_exception(RuntimeError)
    end
  end

  context 'when #set_feature sets stress with value main stress' do
    before do
      s_feat = PAS::Stress.new
      s_feat.set_main_stress
      syllable.set_feature(s_feat.type, s_feat.value)
    end

    it 'has a set stress feature' do
      expect(syllable.stress_unset?).to be false
    end

    it 'has main stress' do
      expect(syllable.main_stress?).to be true
    end
  end

  it '#set_feature raises an exception when given an invalid feature type' do
    expect { syllable.set_feature('invalid', 'value') }.to \
      raise_exception(RuntimeError)
  end

  it '#set_feature does not raise an invalid feature exception when'\
       ' given an unset feature value' do
    expect { syllable.set_feature(PAS::Length::LENGTH, Feature::UNSET) }\
      .not_to raise_exception
  end

  context 'when set to main stress' do
    before do
      syllable.set_main_stress
    end

    it 'does not have an unset stress feature' do
      expect(syllable.stress_unset?).to be false
    end

    it 'has an unset length feature' do
      expect(syllable.length_unset?).to be true
    end

    it 'has main stress' do
      expect(syllable.main_stress?).to be true
    end

    it 'is not unstressed' do
      expect(syllable.unstressed?).to be false
    end
  end

  context 'when set to long' do
    before do
      syllable.set_long
    end

    it 'has an unset stress feature' do
      expect(syllable.stress_unset?).to be true
    end

    it 'does not have an unset length feature' do
      expect(syllable.length_unset?).to be false
    end

    it 'is long' do
      expect(syllable.long?).to be true
    end

    it 'is not short' do
      expect(syllable.short?).to be false
    end
  end

  context 'with s1 stressed and short, s2 stressed and long' do
    before do
      @s1 = described_class.new
      @s1.set_main_stress
      @s1.set_short
      @s2 = described_class.new
      @s2.set_main_stress
      @s2.set_long
    end

    it 'is not ==' do
      expect(@s1 == @s2).to be false
    end

    it 'is not eql?' do
      expect(@s1.eql?(@s2)).to be false
    end

    context 'with a dup of s1' do
      before do
        @dups1 = @s1.dup
      end

      it 'dup == s1' do
        expect(@dups1 == @s1).to be true
      end

      it 'dup is eql to s1' do
        expect(@dups1.eql?(@s1)).to be true
      end

      it 'dup is not equal to s1' do
        expect(@dups1.equal?(@s1)).to be false
      end
    end
  end

  context 'with s1 stressed and short, s2 stressed and short' do
    before do
      @s1 = described_class.new
      @s1.set_main_stress
      @s1.set_short
      @s2 = described_class.new
      @s2.set_main_stress
      @s2.set_short
    end

    it 's1 == s2' do
      expect(@s1 == @s2).to be true
    end

    it 's1 is eql to s2' do
      expect(@s1.eql?(@s2)).to be true
    end
  end
end
