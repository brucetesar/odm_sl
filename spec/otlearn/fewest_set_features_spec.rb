# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/fewest_set_features'

RSpec.describe OTLearn::FewestSetFeatures do
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:prior_result) { double('prior_result') }
  let(:feature_value_finder) { double('feature_value_finder') }
  let(:para_erc_learner) { double('para_erc_learner') }
  let(:pkg1) { double('package 1') }
  let(:pkg2) { double('package 2') }

  before do
    allow(para_erc_learner).to receive(:run)
  end

  context 'with a failed winner' do
    # mocks of internal objects
    let(:failed_winner) { double('failed_winner') }
    let(:unset_feat1) { double('unset_feature_1') }
    let(:unset_feat2) { double('unset_feature_2') }
    let(:fv_pair1) { double('feature-value pair1') }
    let(:fv_pair2) { double('feature-value pair2') }

    before do
      # set up prior_result to return a list with one failed winner
      allow(prior_result).to receive(:failed_winners)\
        .and_return([failed_winner])
      allow(fv_pair1).to receive(:feature_instance).and_return(unset_feat1)
      allow(fv_pair2).to receive(:feature_instance).and_return(unset_feat2)
      allow(fv_pair1).to receive(:set_to_alt_value)
      allow(fv_pair2).to receive(:set_to_alt_value)
      allow(pkg1).to receive(:winner).and_return(failed_winner)
      allow(pkg1).to receive(:values).and_return([fv_pair1])
      allow(pkg2).to receive(:winner).and_return(failed_winner)
      allow(pkg2).to receive(:values).and_return([fv_pair2])
    end

    context 'with one consistent unset feature' do
      before do
        allow(feature_value_finder).to receive(:run)\
          .with(failed_winner, grammar, prior_result)\
          .and_return([pkg1])
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          described_class.new(feature_value_finder: feature_value_finder)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end

      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end

      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner
      end

      it 'determines all of the successful winner/feature pairs' do
        expect(@substep.success_instances).to eq [pkg1]
      end

      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end

      it 'sets the single unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat1
      end

      it 'checks for new ranking information for the unset feature' do
        expect(para_erc_learner).to\
          have_received(:run).with(unset_feat1, grammar, output_list)
      end
    end

    context 'with one inconsistent unset feature' do
      before do
        allow(feature_value_finder).to receive(:run)\
          .with(failed_winner, grammar, prior_result)\
          .and_return([])
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          described_class.new(feature_value_finder: feature_value_finder)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end

      it 'does not set a feature' do
        expect(@substep.changed?).to be false
      end

      it 'does not return a failed winner' do
        expect(@substep.failed_winner).to be_nil
      end

      it 'determines all of the successful winner/feature pairs' do
        expect(@substep.success_instances).to eq []
      end

      it 'sets zero features' do
        expect(@substep.newly_set_features.size).to eq 0
      end

      it 'does not check for new ranking information' do
        expect(para_erc_learner).not_to have_received(:run)
      end
    end

    context 'with two consistent features' do
      before do
        allow(feature_value_finder).to receive(:run)\
          .with(failed_winner, grammar, prior_result)\
          .and_return([pkg1, pkg2])
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          described_class.new(feature_value_finder: feature_value_finder)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end

      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end

      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner
      end

      it 'determines all of the successful winner/feature pairs' do
        expect(@substep.success_instances).to contain_exactly(pkg1, pkg2)
      end

      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end

      it 'sets the single unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat1
      end

      it 'checks for new ranking information for the unset feature' do
        expect(para_erc_learner).to\
          have_received(:run).with(unset_feat1, grammar, output_list)
      end
    end
  end

  context 'with an unsuccessful failed winner and a successful one' do
    let(:failed_winner1) { double('failed_winner1') }
    let(:failed_winner2) { double('failed_winner2') }
    let(:unset_feat1) { double('unset_feature1') }
    let(:unset_feat2) { double('unset_feature2') }
    let(:fv_pair1) { double('feature-value pair1') }
    let(:fv_pair2) { double('feature-value pair2') }

    before do
      # set up prior_result
      allow(prior_result).to\
        receive(:failed_winners)\
        .and_return([failed_winner1, failed_winner2])
      # a test double of FeatureValuePair for dependency injection
      allow(fv_pair1).to receive(:feature_instance).and_return(unset_feat1)
      allow(fv_pair2).to receive(:feature_instance).and_return(unset_feat2)
      allow(fv_pair1).to receive(:set_to_alt_value)
      allow(fv_pair2).to receive(:set_to_alt_value)
      allow(pkg1).to receive(:winner).and_return(failed_winner1)
      allow(pkg1).to receive(:values).and_return([fv_pair1])
      allow(pkg2).to receive(:winner).and_return(failed_winner2)
      allow(pkg2).to receive(:values).and_return([fv_pair2])
    end

    context 'with the first failed winner inconsistent' do
      before do
        allow(feature_value_finder).to receive(:run)\
          .with(failed_winner1, grammar, prior_result)\
          .and_return([])
        allow(feature_value_finder).to receive(:run)\
          .with(failed_winner2, grammar, prior_result)\
          .and_return([pkg2])
        # construct the test object, and inject the test dependencies
        fewest_set_features =
          described_class.new(feature_value_finder: feature_value_finder)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end

      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end

      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner2
      end

      it 'determines all of the successful winner/feature pairs' do
        expect(@substep.success_instances).to eq [pkg2]
      end

      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end

      it 'sets the consistent unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat2
      end

      it 'checks for new ranking information for the unset feature' do
        expect(para_erc_learner).to \
          have_received(:run).with(unset_feat2, grammar, output_list)
      end
    end

    context 'with the first failed winner consistent' do
      before do
        allow(feature_value_finder).to receive(:run)\
          .with(failed_winner1, grammar, prior_result)\
          .and_return([pkg1])
        allow(feature_value_finder).to receive(:run)\
          .with(failed_winner2, grammar, prior_result)\
          .and_return([])
        # actually construct the test object, and inject the test dependencies
        fewest_set_features =
          described_class.new(feature_value_finder: feature_value_finder)
        fewest_set_features.para_erc_learner = para_erc_learner
        @substep = fewest_set_features.run(output_list, grammar, prior_result)
      end

      it 'sets a feature' do
        expect(@substep.changed?).to be true
      end

      it 'determines the failed winner' do
        expect(@substep.failed_winner).to equal failed_winner1
      end

      it 'determines all of the successful winner/feature pairs' do
        expect(@substep.success_instances).to eq [pkg1]
      end

      it 'only sets one feature' do
        expect(@substep.newly_set_features.size).to eq 1
      end

      it 'sets the consistent unset feature' do
        expect(@substep.newly_set_features[0]).to eq unset_feat1
      end

      it 'checks for new ranking information for the unset feature' do
        expect(para_erc_learner).to\
          have_received(:run).with(unset_feat1, grammar, output_list)
      end
    end
  end
end
