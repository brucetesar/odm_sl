# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/syllable'
require 'feature'

RSpec.describe SL::Syllable do
  let(:syllable) { described_class.new }

  it 'has an unset stress feature' do
    expect(syllable).to be_stress_unset
  end

  it 'has an unset length feature' do
    expect(syllable).to be_length_unset
  end

  it 'has morpheme ""' do
    expect(syllable.morpheme).to eq('')
  end

  it 'does not have main stress' do
    expect(syllable).not_to be_main_stress
  end

  it 'is not unstressed' do
    expect(syllable).not_to be_unstressed
  end

  it 'is not long' do
    expect(syllable).not_to be_long
  end

  it 'is not short' do
    expect(syllable).not_to be_short
  end

  it 'has string representation ??' do
    expect(syllable.to_s).to eq '??'
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
      expect(@features[0].type).to eq(SL::Length::LENGTH)
    end

    it 'yields a stress feature' do
      expect(@features[1].type).to eq(SL::Stress::STRESS)
    end
  end

  context 'when set to unstressed and short' do
    before do
      syllable.set_unstressed.set_short
    end

    context 'when #get_feature returns a stress feature' do
      before do
        @s_feat = syllable.get_feature(SL::Stress::STRESS)
      end

      it 'the feature is of type STRESS' do
        expect(@s_feat.type).to eq(SL::Stress::STRESS)
      end

      it 'the feature is unstressed' do
        expect(@s_feat).to be_unstressed
      end
    end

    context 'when #get_feature returns a length feature' do
      before do
        @s_feat = syllable.get_feature(SL::Length::LENGTH)
      end

      it 'the feature is of type LENGTH' do
        expect(@s_feat.type).to eq(SL::Length::LENGTH)
      end

      it 'the feature is short' do
        expect(@s_feat).to be_short
      end
    end

    it 'get_feature raises an exception when given an invalid type' do
      msg = 'Syllable#get_feature(): ' \
            'parameter not_a_type is not a valid feature type.'
      expect { syllable.get_feature('not_a_type') }.to \
        raise_error(RuntimeError, msg)
    end
  end

  context 'when #set_feature sets stress with value main stress' do
    before do
      s_feat = SL::Stress.new
      s_feat.set_main_stress
      syllable.set_feature(s_feat.type, s_feat.value)
    end

    it 'has a set stress feature' do
      expect(syllable).not_to be_stress_unset
    end

    it 'has main stress' do
      expect(syllable).to be_main_stress
    end
  end

  it '#set_feature raises an exception on invalid feature type' do
    msg = 'Syllable#get_feature(): ' \
          'parameter invalid is not a valid feature type.'
    expect { syllable.set_feature('invalid', 'value') }.to \
      raise_exception(RuntimeError, msg)
  end

  it '#set_feature does not raise an exception on unset feature' do
    expect { syllable.set_feature(SL::Length::LENGTH, Feature::UNSET) }\
      .not_to raise_exception
  end

  context 'when set to main stress' do
    before do
      syllable.set_main_stress
    end

    it 'does not have an unset stress feature' do
      expect(syllable).not_to be_stress_unset
    end

    it 'has an unset length feature' do
      expect(syllable).to be_length_unset
    end

    it 'has main stress' do
      expect(syllable).to be_main_stress
    end

    it 'is not unstressed' do
      expect(syllable).not_to be_unstressed
    end
  end

  context 'when set to long' do
    before do
      syllable.set_long
    end

    it 'has an unset stress feature' do
      expect(syllable).to be_stress_unset
    end

    it 'does not have an unset length feature' do
      expect(syllable).not_to be_length_unset
    end

    it 'is long' do
      expect(syllable).to be_long
    end

    it 'is not short' do
      expect(syllable).not_to be_short
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

    it 's1 not == s2' do
      expect(@s1 == @s2).to be false
    end

    it 's1 is not eql to s2' do
      expect(@s1).not_to be_eql @s2
    end

    context 'with a dup of s1' do
      before do
        @dups1 = @s1.dup
      end

      it 'dup == s1' do
        expect(@dups1 == @s1).to be true
      end

      it 'dup is eql to s1' do
        expect(@dups1).to be_eql @s1
      end

      it 'dup is not equal to s1' do
        expect(@dups1).not_to be_equal @s1
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
      expect(@s1).to be_eql @s2
    end
  end
end
