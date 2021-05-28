# frozen_string_literal: true

# Author: Bruce Tesar

require 'feature_instance'

RSpec.describe FeatureInstance do
  let(:element) { double('element') }
  let(:feature) { double('feature') }

  context 'when newly constructed' do
    before do
      type = 'some_type'
      allow(feature).to receive(:type).and_return(type)
      allow(feature).to receive(:value).and_return('the_value')
      allow(feature).to receive(:value=)
      allow(feature).to receive(:unset).and_return(feature)
      allow(element).to receive(:get_feature).with(type).and_return(feature)
      allow(element).to receive(:morpheme).and_return('the_morph')
      @feature_instance = described_class.new(element, feature)
    end

    it 'returns the provided element' do
      expect(@feature_instance.element).to equal(element)
    end

    it 'returns the provided feature' do
      expect(@feature_instance.feature).to equal(feature)
    end

    it 'returns the morpheme of the provided element' do
      expect(@feature_instance.morpheme).to eq('the_morph')
    end

    it 'returns the value of the feature' do
      expect(feature.value).to eq('the_value')
    end

    it 'allows the feature value to be set to a different value' do
      @feature_instance.value = 'new_value'
      expect(feature).to have_received(:value=).with('new_value')
    end

    it 'allows the feature to be unset' do
      @feature_instance.unset
      expect(feature).to have_received(:unset)
    end

    it 'returns a reference to self when unset' do
      rvalue = @feature_instance.unset
      expect(rvalue).to eq @feature_instance
    end
  end

  context 'with a feature that does not belong to the element' do
    before do
      type = 'some_type'
      allow(feature).to receive(:type).and_return(type)
      # returns a copy, equivalent in every way but not the same object
      allow(element).to\
        receive(:get_feature).with(type).and_return(feature.dup)
    end

    it 'raises an exception' do
      expect { described_class.new(element, feature) }.to\
        raise_exception(RuntimeError,
                        'The feature must belong to the element')
    end
  end
end
