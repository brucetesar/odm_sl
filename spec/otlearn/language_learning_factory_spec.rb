# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/language_learning_factory'

RSpec.describe 'OTLearn::LanguageLearningFactory' do
  let(:system) { double('system') }
  before(:example) do
    @name_msg = 'OTLearn::LanguageLearningFactory#build:'
    @factory = OTLearn::LanguageLearningFactory.new
  end

  context 'when set to faith_low, learning ctie, testing consistent,' do
    before(:example) do
      @factory.para_faith_low.learn_ctie.test_consistent
      @factory.system = system
      @learner = @factory.build
    end
    it 'creates a learner with a phonotactic learner' do
      expect(@learner.ph_learner).to respond_to(:run)
    end
    it 'creates a learner with a single form learner' do
      expect(@learner.sf_learner).to respond_to(:run)
    end
    it 'creates a learner with a contrast pair learner' do
      expect(@learner.cp_learner).to respond_to(:run)
    end
    it 'creates a learner with an induction learner' do
      expect(@learner.in_learner).to respond_to(:run)
    end
  end

  context 'when set to mark_low, learning pool, testing ctie,' do
    before(:example) do
      @factory.para_mark_low.learn_pool.test_ctie
      @factory.system = system
      @learner = @factory.build
    end
    it 'creates a learner with a phonotactic learner' do
      expect(@learner.ph_learner).to respond_to(:run)
    end
    it 'creates a learner with a single form learner' do
      expect(@learner.sf_learner).to respond_to(:run)
    end
    it 'creates a learner with a contrast pair learner' do
      expect(@learner.cp_learner).to respond_to(:run)
    end
    it 'creates a learner with an induction learner' do
      expect(@learner.in_learner).to respond_to(:run)
    end
  end

  context 'without specifying a system' do
    before(:example) do
      @factory.para_all_high.learn_consistent.test_pool
    end
    it 'raises a RuntimeError' do
      emsg = "#{@name_msg} no system specified."
      expect { @factory.build }.to raise_error(RuntimeError, emsg)
    end
  end
  context 'without specifying a paradigmatic ranking bias' do
    before(:example) do
      @factory.learn_consistent.test_pool
      @factory.system = system
    end
    it 'raises a RuntimeError' do
      emsg = "#{@name_msg} no paradigmatic ranking bias specified."
      expect { @factory.build }.to raise_error(RuntimeError, emsg)
    end
  end
  context 'without specifying a learn compare type' do
    before(:example) do
      @factory.para_all_high.test_pool
      @factory.system = system
    end
    it 'raises a RuntimeError' do
      emsg = "#{@name_msg} no learning compare type specified."
      expect { @factory.build }.to raise_error(RuntimeError, emsg)
    end
  end
  context 'without specifying a test compare type' do
    before(:example) do
      @factory.para_all_high.learn_consistent
      @factory.system = system
    end
    it 'raises a RuntimeError' do
      emsg = "#{@name_msg} no testing compare type specified."
      expect { @factory.build }.to raise_error(RuntimeError, emsg)
    end
  end
end
