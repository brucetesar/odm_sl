# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/fsf_substep'
require 'otlearn/otlearn'

RSpec.describe OTLearn::FsfSubstep do
  let(:set_features) { double('set_features') }
  let(:newly_set_fv_pair) { double('newly_set_fv_pair') }
  let(:newly_set_feature) { double('newly_set_feature') }
  let(:failed_winner) { double('failed_winner') }
  let(:success_instances) { double('success_instances') }

  context 'with no newly set features' do
    before do
      allow(set_features).to receive(:winner).and_return(failed_winner)
      allow(set_features).to receive(:values).and_return([])
      @substep = described_class.new(set_features, success_instances)
    end

    it 'indicates a subtype of FewestSetFeatures' do
      expect(@substep.subtype).to eq OTLearn::FEWEST_SET_FEATURES
    end

    it 'returns an empty list of newly set features' do
      expect(@substep.newly_set_features).to be_empty
    end

    it 'returns the failed winner' do
      expect(@substep.failed_winner).to eq failed_winner
    end

    it 'returns the list of successful feature instances' do
      expect(@substep.success_instances).to eq success_instances
    end

    it 'indicates that the grammar has not changed' do
      expect(@substep.changed?).to be false
    end
  end

  context 'with one newly set feature' do
    before do
      allow(set_features).to receive(:winner).and_return(failed_winner)
      allow(set_features).to receive(:values).and_return([newly_set_fv_pair])
      allow(newly_set_fv_pair).to \
        receive(:feature_instance).and_return(newly_set_feature)
      @substep = described_class.new(set_features, success_instances)
    end

    it 'indicates a subtype of FewestSetFeatures' do
      expect(@substep.subtype).to eq OTLearn::FEWEST_SET_FEATURES
    end

    it 'returns the list of newly set features' do
      expect(@substep.newly_set_features).to contain_exactly(newly_set_fv_pair)
    end

    it 'returns the failed winner' do
      expect(@substep.failed_winner).to eq failed_winner
    end

    it 'returns the list of successful feature instances' do
      expect(@substep.success_instances).to eq success_instances
    end

    it 'indicates that the grammar has changed' do
      expect(@substep.changed?).to be true
    end
  end
end
