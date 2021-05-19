# frozen_string_literal: true

# Author: Bruce Tesar

require 'sl/length'

RSpec.describe SL::Length do
  let(:length) { SL::Length::LENGTH }
  let(:short) { SL::Length::SHORT }
  let(:long) { SL::Length::LONG }
  let(:feature) { described_class.new }

  it 'has type LENGTH' do
    expect(feature.type).to eq length
  end

  it 'is unset' do
    expect(feature.unset?).to be true
  end

  it 'is not short' do
    expect(feature.short?).to be false
  end

  it 'is not long' do
    expect(feature.long?).to be false
  end

  it 'returns a string value of length=unset' do
    expect(feature.to_s).to eq('length=unset')
  end

  it 'accepts short as a valid value' do
    expect(feature.valid_value?(short)).to be true
  end

  it 'accepts long as a valid value' do
    expect(feature.valid_value?(long)).to be true
  end

  it 'does not accept :invalid as a valid value' do
    expect(feature.valid_value?(:invalid)).to be false
  end

  it 'iterates over the feature values' do
    expect { |probe| feature.each_value(&probe) }.to\
      yield_successive_args(short, long)
  end

  context 'when set to short' do
    before do
      feature.set_short
    end

    it 'is set' do
      expect(feature.unset?).to be false
    end

    it 'is short' do
      expect(feature.short?).to be true
    end

    it 'is not long' do
      expect(feature.long?).to be false
    end

    it 'returns a string value of length=short' do
      expect(feature.to_s).to eq('length=short')
    end
  end

  context 'when set to long' do
    before do
      feature.set_long
    end

    it 'is set' do
      expect(feature.unset?).to be false
    end

    it 'is not short' do
      expect(feature.short?).to be false
    end

    it 'is long' do
      expect(feature.long?).to be true
    end

    it 'returns a string value of length=long' do
      expect(feature.to_s).to eq('length=long')
    end
  end
end
