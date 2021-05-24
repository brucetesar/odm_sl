# frozen_string_literal: true

# Author: Bruce Tesar

require 'pas/stress'

RSpec.describe PAS::Stress do
  let(:stress) { PAS::Stress::STRESS }
  let(:unstressed) { PAS::Stress::UNSTRESSED }
  let(:main_stress) { PAS::Stress::MAIN_STRESS }
  let(:feature) { described_class.new }

  it 'has type STRESS' do
    expect(feature.type).to eq stress
  end

  it 'is unset' do
    expect(feature.unset?).to be true
  end

  it 'is not unstressed' do
    expect(feature.unstressed?).to be false
  end

  it 'is not stressed' do
    expect(feature.main_stress?).to be false
  end

  it 'returns a string value of stress=unset' do
    expect(feature.to_s).to eq('stress=unset')
  end

  it 'accepts unstressed as a valid value' do
    expect(feature.valid_value?(unstressed)).to be true
  end

  it 'accepts main_stress as a valid value' do
    expect(feature.valid_value?(main_stress)).to be true
  end

  it 'does not accept :invalid as a valid value' do
    expect(feature.valid_value?(:invalid)).to be false
  end

  it 'iterates over the feature values' do
    expect { |probe| feature.each_value(&probe) }.to\
      yield_successive_args(unstressed, main_stress)
  end

  context 'when set to unstressed' do
    before do
      feature.set_unstressed
    end

    it 'is set' do
      expect(feature.unset?).to be false
    end

    it 'is unstressed' do
      expect(feature.unstressed?).to be true
    end

    it 'is not stressed' do
      expect(feature.main_stress?).to be false
    end

    it 'returns a string value of stress=unstressed' do
      expect(feature.to_s).to eq('stress=unstressed')
    end
  end

  context 'when set to main_stress' do
    before do
      feature.set_main_stress
    end

    it 'is set' do
      expect(feature.unset?).to be false
    end

    it 'is not unstressed' do
      expect(feature.unstressed?).to be false
    end

    it 'is stressed' do
      expect(feature.main_stress?).to be true
    end

    it 'returns a string value of stress=main_stress' do
      expect(feature.to_s).to eq('stress=main_stress')
    end
  end
end
