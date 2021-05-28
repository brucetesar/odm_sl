# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'feature_value_pair'

RSpec.describe FeatureValuePair do
  let(:f_inst) { double('feature instance') }
  let(:feature) { double('feature') }
  let(:value) { double('value') }
  let(:f_type) { double('feature type') }

  before do
    allow(f_inst).to receive(:feature).and_return(feature)
    allow(feature).to receive(:type).and_return(f_type)
  end

  context 'with a feature instance and a valid value' do
    before do
      allow(feature).to receive(:valid_value?).with(value).and_return(true)
      @fvp = described_class.new(f_inst, value)
    end

    it 'returns the feature instance' do
      expect(@fvp.feature_instance).to eq f_inst
    end

    it 'returns the given value' do
      expect(@fvp.alt_value).to eq value
    end

    context 'when set_to_alt_value is called' do
      before do
        allow(feature).to receive(:value=)
        @fvp.set_to_alt_value
      end

      it 'sets the value' do
        expect(feature).to have_received(:value=).with(value)
      end
    end
  end

  context 'with an invalid value' do
    let(:other_value) { double('other_value') }

    before do
      allow(feature).to receive(:valid_value?).with(value).and_return(false)
    end

    it 'raises a RuntimeError' do
      expect { described_class.new(f_inst, value) }.to\
        raise_error(RuntimeError)
    end
  end
end
