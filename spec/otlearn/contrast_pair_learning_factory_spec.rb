# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/contrast_pair_learning_factory'

RSpec.describe 'OTLearn::ContrastPairLearningFactory' do
  let(:system) { double('system') }
  let(:learning_comparer) { double('learning comparer') }
  let(:testing_comparer) { double('testing comparer') }
  before(:example) do
    @factory = OTLearn::ContrastPairLearningFactory.new
  end

  context 'given a learning comparer and a testing comparer' do
    before(:example) do
      @factory.system = system
      @factory.learning_comparer = learning_comparer
      @factory.testing_comparer = testing_comparer
      @cp_learn = @factory.build
    end
    it 'creates a learner with the learning comparer' do
      para_erc_learner = @cp_learn.para_erc_learner
      learn_loser_selector = para_erc_learner.erc_learner.loser_selector
      # If a loser selector isn't externally provided to erc learner,
      # the default isn't assigned until ErcLearning#run is called.
      expect(learn_loser_selector).not_to be_nil
      learn_comparer = learn_loser_selector.comparer
      expect(learn_comparer).to eq learning_comparer
    end
    it 'creates a learner with the testing comparer' do
      tester = @cp_learn.grammar_tester
      test_loser_selector = tester.loser_selector
      # If a loser selector isn't externally provided,
      # the default isn't assigned until GrammarTest#run is called.
      expect(test_loser_selector).not_to be_nil
      test_comparer = test_loser_selector.comparer
      expect(test_comparer).to eq testing_comparer
    end
  end

  context 'without specifying a system' do
    before(:example) do
      @factory.learning_comparer = learning_comparer
      @factory.testing_comparer = testing_comparer
    end
    it 'raises a RuntimeError' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end
  context 'without specifying a learning comparer' do
    before(:example) do
      @factory.system = system
      @factory.testing_comparer = testing_comparer
    end
    it 'raises a RuntimeError' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end
  context 'without specifying a testing comparer' do
    before(:example) do
      @factory.system = system
      @factory.learning_comparer = learning_comparer
    end
    it 'raises a RuntimeError' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end
end
