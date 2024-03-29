# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'feature_value_combiner'

RSpec.describe FeatureValueCombiner do
  let(:fvp_class) { double('FeatureValuePair class') }
  let(:finst1) { double('feature instance 1') }
  let(:feat1) { double('feature 1') }
  let(:value11) { double('feature value 11') }
  let(:value12) { double('feature value 12') }
  let(:fvp11) { double('FeatureValuePair 11') }
  let(:fvp12) { double('FeatureValuePair 12') }
  let(:finst2) { double('feature instance 2') }
  let(:feat2) { double('feature 2') }
  let(:value21) { double('feature value 21') }
  let(:value22) { double('feature value 22') }
  let(:fvp21) { double('FeatureValuePair 21') }
  let(:fvp22) { double('FeatureValuePair 22') }

  before do
    allow(finst1).to receive(:feature).and_return(feat1)
    allow(feat1).to receive(:each_value).and_yield(value11)\
                                        .and_yield(value12)
    allow(fvp_class).to receive(:new).with(finst1, value11)\
                                     .and_return(fvp11)
    allow(fvp_class).to receive(:new).with(finst1, value12)\
                                     .and_return(fvp12)
    allow(finst2).to receive(:feature).and_return(feat2)
    allow(feat2).to receive(:each_value).and_yield(value21)\
                                        .and_yield(value22)
    allow(fvp_class).to receive(:new).with(finst2, value21)\
                                     .and_return(fvp21)
    allow(fvp_class).to receive(:new).with(finst2, value22)\
                                     .and_return(fvp22)
    @combiner = described_class.new(fvp_class: fvp_class)
  end

  context 'when values_by_feature is called with one feature' do
    before do
      feature_instance_list = [finst1]
      @avp_list = @combiner.values_by_feature(feature_instance_list)
      @fvp_list = @avp_list[0]
    end

    it 'returns a list with one entry for one feature' do
      expect(@avp_list.size).to eq(1)
    end

    it 'returns an entry of two value pairs for the feature' do
      expect(@fvp_list).to contain_exactly(fvp11, fvp12)
    end
  end

  context 'when values_by_feature is called with two features' do
    before do
      feature_instance_list = [finst1, finst2]
      @avp_list = @combiner.values_by_feature(feature_instance_list)
      @fvp_list1 = @avp_list[0]
      @fvp_list2 = @avp_list[1]
    end

    it 'returns a list with two entries for two features' do
      expect(@avp_list.size).to eq(2)
    end

    it 'returns an entry of two value pairs for the first feature' do
      expect(@fvp_list1).to contain_exactly(fvp11, fvp12)
    end

    it 'returns an entry of two value pairs for the second feature' do
      expect(@fvp_list2).to contain_exactly(fvp21, fvp22)
    end
  end

  context 'when feature_value_combinations is called with one feature' do
    before do
      feature_instance_list = [finst1]
      @comb_list =
        @combiner.feature_value_combinations(feature_instance_list)
    end

    it 'returns a list with two combinations' do
      expect(@comb_list.size).to eq(2)
    end

    it 'returns a combination with the first feature value' do
      expect(@comb_list[0]).to contain_exactly(fvp11)
    end

    it 'returns a combination with the second feature value' do
      expect(@comb_list[1]).to contain_exactly(fvp12)
    end
  end

  context 'when feature_value_combinations is called with two features' do
    before do
      feature_instance_list = [finst1, finst2]
      @comb_list =
        @combiner.feature_value_combinations(feature_instance_list)
    end

    it 'returns a list with four combinations' do
      expect(@comb_list.size).to eq(4)
    end

    it 'returns a combination with values 11 and 21' do
      expect(@comb_list[0]).to contain_exactly(fvp11, fvp21)
    end

    it 'returns a combination with values 11 and 22' do
      expect(@comb_list[1]).to contain_exactly(fvp11, fvp22)
    end

    it 'returns a combination with values 12 and 21' do
      expect(@comb_list[2]).to contain_exactly(fvp12, fvp21)
    end

    it 'returns a combination with values 12 and 22' do
      expect(@comb_list[3]).to contain_exactly(fvp12, fvp22)
    end
  end
end
