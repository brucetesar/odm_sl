# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/fsf_substep'
require 'otlearn/otlearn'
require 'word_values_package'
require 'feature_value_pair'

RSpec.describe OTLearn::FsfSubstep do
  context 'with no consistent package' do
    before do
      @substep = described_class.new(nil, [])
    end

    it 'indicates a subtype of FewestSetFeatures' do
      expect(@substep.subtype).to eq OTLearn::FEWEST_SET_FEATURES
    end

    it 'returns no chosen package' do
      expect(@substep.chosen_package).to be_nil
    end

    it 'returns an empty list of consistent packages' do
      expect(@substep.consistent_packages).to be_empty
    end

    it 'indicates that the grammar has not changed' do
      expect(@substep.changed?).to be false
    end
  end

  context 'with one newly set feature' do
    let(:chosen_package) \
    { instance_double(WordValuesPackage, 'chosen_package') }
    let(:newly_set_fv_pair) \
    { instance_double(FeatureValuePair, 'newly_set_fv_pair') }
    let(:consistent_packages) { [newly_set_fv_pair] }

    before do
      allow(chosen_package).to \
        receive(:values).and_return([newly_set_fv_pair])
      @substep = described_class.new(chosen_package, consistent_packages)
    end

    it 'indicates a subtype of FewestSetFeatures' do
      expect(@substep.subtype).to eq OTLearn::FEWEST_SET_FEATURES
    end

    it 'returns the chosen package' do
      expect(@substep.chosen_package).to eq chosen_package
    end

    it 'returns the list of consistent packages' do
      expect(@substep.consistent_packages).to eq consistent_packages
    end

    it 'indicates that the grammar has changed' do
      expect(@substep.changed?).to be true
    end
  end
end
