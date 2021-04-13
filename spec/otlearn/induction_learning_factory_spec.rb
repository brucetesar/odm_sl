# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/induction_learning_factory'

RSpec.describe 'OTLearn::InductionLearningFactory' do
  let(:system) { double('system') }
  let(:learning_comparer) { double('learning comparer') }
  let(:testing_comparer) { double('testing comparer') }
  before(:example) do
    @factory = OTLearn::InductionLearningFactory.new
  end

  context 'given a learning comparer and a testing comparer' do
    before(:example) do
      @factory.system = system
      @factory.learning_comparer = learning_comparer
      @factory.testing_comparer = testing_comparer
      @in_learn = @factory.build
    end
    it 'creates an MMR learner with the testing comparer' do
      erc_learner = @in_learn.mmr_learner.erc_learner
      loser_selector = erc_learner.loser_selector
      comparer = loser_selector.comparer
      expect(comparer).to eq testing_comparer
    end
    it 'creates an FSF learner with the testing comparer' do
      para_erc_learner = @in_learn.fsf_learner.para_erc_learner
      learn_loser_selector = para_erc_learner.erc_learner.loser_selector
      comparer = learn_loser_selector.comparer
      expect(comparer).to eq testing_comparer
    end
    it 'creates a learner with the testing comparer' do
      tester = @in_learn.grammar_tester
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
