# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/phonotactic_learning_factory'

RSpec.describe OTLearn::PhonotacticLearningFactory do
  let(:system) { double('system') }
  let(:learning_comparer) { double('learning comparer') }
  let(:testing_comparer) { double('testing comparer') }

  before do
    @factory = described_class.new
  end

  context 'with a learning comparer and a testing comparer' do
    before do
      @factory.system = system
      @factory.learning_comparer = learning_comparer
      @factory.testing_comparer = testing_comparer
      @ph_learn = @factory.build
    end

    it 'creates a learner with the learning comparer' do
      erc_learner = @ph_learn.erc_learner
      learn_loser_selector = erc_learner.loser_selector
      # If a loser selector isn't externally provided to erc learner,
      # the default isn't assigned until ErcLearning#run is called.
      learn_comparer = learn_loser_selector.comparer
      expect(learn_comparer).to eq learning_comparer
    end

    it 'creates a learner with the testing comparer' do
      tester = @ph_learn.grammar_tester
      test_loser_selector = tester.loser_selector
      # If a loser selector isn't externally provided,
      # the default isn't assigned until GrammarTest#run is called.
      test_comparer = test_loser_selector.comparer
      expect(test_comparer).to eq testing_comparer
    end
  end

  context 'without specifying a system' do
    before do
      @factory.learning_comparer = learning_comparer
      @factory.testing_comparer = testing_comparer
    end

    it 'raises a RuntimeError' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end

  context 'without specifying a learning comparer' do
    before do
      @factory.system = system
      @factory.testing_comparer = testing_comparer
    end

    it 'raises a RuntimeError' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end

  context 'without specifying a testing comparer' do
    before do
      @factory.system = system
      @factory.learning_comparer = learning_comparer
    end

    it 'raises a RuntimeError' do
      expect { @factory.build }.to raise_error(RuntimeError)
    end
  end
end
