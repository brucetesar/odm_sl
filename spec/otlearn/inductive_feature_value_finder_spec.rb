# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/consistency_checker'
require 'word_search'
require 'feature_value_pair'
require 'output'
require 'word'
require 'grammar'
require 'otlearn/grammar_test_result'
require 'otlearn/inductive_feature_value_finder'

RSpec.describe OTLearn::InductiveFeatureValueFinder do
  let(:consistency_checker) do
    instance_double(OTLearn::ConsistencyChecker, 'consistency_checker')
  end
  let(:word_search) { instance_double(WordSearch, 'word_search') }
  let(:fv_pair_class) { class_double(FeatureValuePair, 'fv_pair_class') }
  let(:winner) { double('winner') }
  let(:winner_dup) { double('winner_dup') }
  let(:output) { instance_double(Output, 'output') }
  let(:grammar) { instance_double(Grammar, 'grammar') }
  let(:test_result) do
    instance_double(OTLearn::GrammarTestResult, 'test_result')
  end
  let(:unset_feature1) { double('unset_feature1') }
  let(:unset_feature2) { double('unset_feature2') }
  let(:out_feature1) { double('out_feature1') }
  let(:out_feature2) { double('out_feature2') }
  let(:out_value1) { double('out_value1') }
  let(:out_value2) { double('out_value2') }
  let(:fv1) { instance_double(FeatureValuePair, 'feature_value1') }
  let(:fv2) { instance_double(FeatureValuePair, 'feature_value2') }

  before do
    @finder = described_class.new(consistency_checker: consistency_checker,
                                  word_search: word_search,
                                  fv_pair_class: fv_pair_class)
    allow(test_result).to receive(:success_winners).and_return([])
    allow(fv_pair_class).to receive(:new).with(unset_feature1, out_value1)\
                                         .and_return(fv1)
    allow(fv_pair_class).to receive(:new).with(unset_feature2, out_value2)\
                                         .and_return(fv2)
    allow(winner).to receive(:output).and_return(output)
    allow(grammar).to receive(:parse_output).with(output)\
                                            .and_return(winner_dup)
    allow(winner_dup).to receive(:out_feat_corr_of_uf)\
      .with(unset_feature1).and_return(out_feature1)
    allow(winner_dup).to receive(:out_feat_corr_of_uf)\
      .with(unset_feature2).and_return(out_feature2)
    allow(winner_dup).to receive(:output).and_return(output)
    allow(out_feature1).to receive(:value).and_return(out_value1)
    allow(out_feature2).to receive(:value).and_return(out_value2)
    allow(unset_feature1).to receive(:value=).with(out_value1)
    allow(unset_feature2).to receive(:value=).with(out_value2)
    allow(unset_feature1).to receive(:value).and_return(out_value1)
    allow(unset_feature2).to receive(:value).and_return(out_value2)
    allow(unset_feature1).to receive(:unset)
    allow(unset_feature2).to receive(:unset)
  end

  context 'when one feature value is successful' do
    before do
      allow(word_search).to receive(:find_unset_features_in_words)\
        .with([winner_dup], grammar).and_return([unset_feature1])
      allow(consistency_checker).to receive(:mismatch_consistent?)\
        .with([output], grammar).and_return(true)
      @result = @finder.run(winner, grammar, test_result)
    end

    it 'returns a list with exactly one success set' do
      expect(@result.size).to eq 1
    end

    it 'returns the successful feature value' do
      expect(@result[0].values).to contain_exactly(fv1)
    end

    it 'returns the failed winner' do
      expect(@result[0].word).to eq winner
    end
  end

  context 'when one feature value is unsuccessful' do
    before do
      allow(word_search).to receive(:find_unset_features_in_words)\
        .with([winner_dup], grammar).and_return([unset_feature1])
      allow(consistency_checker).to receive(:mismatch_consistent?)\
        .with([output], grammar).and_return(false)
      @result = @finder.run(winner, grammar, test_result)
    end

    it 'returns a list with no success sets' do
      expect(@result).to be_empty
    end
  end

  context 'when one of two feature values is successful' do
    before do
      allow(word_search).to receive(:find_unset_features_in_words)\
        .with([winner_dup], grammar)\
        .and_return([unset_feature1, unset_feature2])
      allow(consistency_checker).to receive(:mismatch_consistent?)\
        .with([output], grammar).and_return(false, true)
      @result = @finder.run(winner, grammar, test_result)
    end

    it 'returns a list with exactly one success set' do
      expect(@result.size).to eq 1
    end

    it 'returns the successful feature value' do
      expect(@result[0].values).to contain_exactly(fv2)
    end

    it 'returns the failed winner' do
      expect(@result[0].word).to eq winner
    end
  end

  context 'when two feature values are successful' do
    before do
      allow(word_search).to receive(:find_unset_features_in_words)\
        .with([winner_dup], grammar)\
        .and_return([unset_feature1, unset_feature2])
      allow(consistency_checker).to receive(:mismatch_consistent?)\
        .with([output], grammar).and_return(true, true)
      @result = @finder.run(winner, grammar, test_result)
    end

    it 'returns a list with exactly two success sets' do
      expect(@result.size).to eq 2
    end

    it 'returns the first successful feature value' do
      expect(@result[0].values).to contain_exactly(fv1)
    end

    it 'returns the failed winner for the first feature' do
      expect(@result[0].word).to eq winner
    end

    it 'returns the second successful feature value' do
      expect(@result[1].values).to contain_exactly(fv2)
    end

    it 'returns the failed winner for the second feature' do
      expect(@result[1].word).to eq winner
    end
  end
end
