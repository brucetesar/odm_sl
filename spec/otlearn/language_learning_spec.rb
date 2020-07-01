# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/language_learning'
require 'otlearn/otlearn'
require 'stringio'

RSpec.describe OTLearn::LanguageLearning do
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:phonotactic_learning_class) { double('phonotactic_learning_class') }
  let(:single_form_learning_class) { double('single_form_learning_class') }
  let(:contrast_pair_learning_class) { double('contrast_pair_learning_class') }
  let(:induction_learning_class) { double('induction_learning_class') }
  let(:loser_selector) { double('loser_selector') }
  let(:pl_obj) { double('pl_obj') }
  let(:pl_step) { double('pl_step') }
  let(:sfl_obj1) { double('sfl_obj1') }
  let(:sfl_obj2) { double('sfl_obj2') }
  let(:sfl_step1) { double('sfl_step1') }
  let(:sfl_step2) { double('sfl_step2') }
  let(:cpl_obj) { double('cpl_obj') }
  let(:cpl_step) { double('cpl_step') }
  let(:il_obj) { double('il_obj') }
  before(:example) do
    allow(phonotactic_learning_class).to receive(:new)
    allow(single_form_learning_class).to receive(:new)
    allow(contrast_pair_learning_class).to receive(:new)
    allow(induction_learning_class).to receive(:new)
    allow(grammar).to receive(:label)
  end

  context 'given phontactically learnable data' do
    before(:example) do
      allow(phonotactic_learning_class).to \
        receive(:new).and_return(pl_obj)
      allow(pl_obj).to receive(:run).and_return(pl_step)
      allow(pl_step).to receive(:all_correct?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.phonotactic_learning_class =
        phonotactic_learning_class
      @language_learning.single_form_learning_class =
        single_form_learning_class
      @language_learning.contrast_pair_learning_class =
        contrast_pair_learning_class
      @language_learning.induction_learning_class =
        induction_learning_class
      @language_learning.loser_selector = loser_selector
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(phonotactic_learning_class).to have_received(:new)
    end
    it 'has phonotactic learning as its only learning step' do
      expect(@result.step_list).to eq [pl_step]
    end
    it 'does not call single form learning' do
      expect(single_form_learning_class).not_to have_received(:new)
    end
    it 'does not call contrast pair learning' do
      expect(contrast_pair_learning_class).not_to have_received(:new)
    end
    it 'does not call induction learning' do
      expect(induction_learning_class).not_to have_received(:new)
    end
  end

  context 'given single form learnable data' do
    before(:example) do
      allow(phonotactic_learning_class).to receive(:new).and_return(pl_obj)
      allow(pl_obj).to receive(:run).and_return(pl_step)
      allow(pl_step).to receive(:all_correct?).and_return(false)
      allow(single_form_learning_class).to \
        receive(:new).and_return(sfl_obj1)
      allow(sfl_obj1).to receive(:run).and_return(sfl_step1)
      allow(sfl_step1).to receive(:all_correct?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.phonotactic_learning_class =
        phonotactic_learning_class
      @language_learning.single_form_learning_class =
        single_form_learning_class
      @language_learning.contrast_pair_learning_class =
        contrast_pair_learning_class
      @language_learning.induction_learning_class =
        induction_learning_class
      @language_learning.loser_selector = loser_selector
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(phonotactic_learning_class).to have_received(:new)
    end
    it 'calls single form learning one time' do
      expect(single_form_learning_class).to have_received(:new)\
        .exactly(1).times
    end
    it 'has PL and SFL learning steps' do
      expect(@result.step_list).to eq [pl_step, sfl_step1]
    end
    it 'does not call contrast pair learning' do
      expect(contrast_pair_learning_class).not_to have_received(:new)
    end
    it 'does not call induction learning' do
      expect(induction_learning_class).not_to have_received(:new)
    end
  end

  context 'given single contrast pair learnable data' do
    before(:example) do
      allow(phonotactic_learning_class).to \
        receive(:new).and_return(pl_obj)
      allow(pl_obj).to receive(:run).and_return(pl_step)
      allow(pl_step).to receive(:all_correct?).and_return(false)
      allow(single_form_learning_class).to \
        receive(:new).and_return(sfl_obj1, sfl_obj2)
      allow(sfl_obj1).to receive(:run).and_return(sfl_step1)
      allow(sfl_step1).to receive(:all_correct?).and_return(false)
      allow(sfl_obj2).to receive(:run).and_return(sfl_step2)
      allow(sfl_step2).to receive(:test_result)
      allow(sfl_step2).to receive(:all_correct?).and_return(true)
      allow(contrast_pair_learning_class).to \
        receive(:new).and_return(cpl_obj)
      allow(cpl_obj).to receive(:run).and_return(cpl_step)
      allow(cpl_step).to receive(:all_correct?).and_return(false)
      allow(cpl_step).to receive(:changed?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.phonotactic_learning_class =
        phonotactic_learning_class
      @language_learning.single_form_learning_class =
        single_form_learning_class
      @language_learning.contrast_pair_learning_class =
        contrast_pair_learning_class
      @language_learning.induction_learning_class =
        induction_learning_class
      @language_learning.loser_selector = loser_selector
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(phonotactic_learning_class).to have_received(:new)
    end
    it 'calls single form learning two times' do
      expect(single_form_learning_class).to\
        have_received(:new).exactly(2).times
    end
    it 'has PL, SFL, CPL, and SFL learning steps' do
      expect(@result.step_list).to\
        eq [pl_step, sfl_step1, cpl_step, sfl_step2]
    end
    it 'calls contrast pair learning one time' do
      expect(contrast_pair_learning_class).to\
        have_received(:new).exactly(1).times
    end
    it 'does not call induction learning' do
      expect(induction_learning_class).not_to have_received(:new)
    end
  end

  context 'given single induction step learnable data' do
    before(:example) do
      allow(phonotactic_learning_class).to \
        receive(:new).and_return(pl_obj)
      allow(pl_obj).to receive(:run).and_return(pl_step)
      allow(pl_step).to receive(:all_correct?).and_return(false)
      allow(single_form_learning_class).to \
        receive(:new).and_return(sfl_obj1, sfl_obj2)
      allow(sfl_obj1).to receive(:run).and_return(sfl_step1)
      allow(sfl_step1).to receive(:all_correct?).and_return(false)
      allow(sfl_obj2).to receive(:run).and_return(sfl_step2)
      allow(sfl_step2).to receive(:all_correct?).and_return(true)
      allow(contrast_pair_learning_class).to \
        receive(:new).and_return(cpl_obj)
      allow(cpl_obj).to receive(:run).and_return(cpl_step)
      allow(cpl_step).to receive(:all_correct?).and_return(false)
      allow(cpl_step).to receive(:changed?).and_return(false)
      allow(induction_learning_class).to receive(:new).and_return(il_obj)
      allow(il_obj).to receive(:run)
      allow(il_obj).to receive(:all_correct?).and_return(false)
      allow(il_obj).to receive(:changed?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new
      @language_learning.phonotactic_learning_class =
        phonotactic_learning_class
      @language_learning.single_form_learning_class =
        single_form_learning_class
      @language_learning.contrast_pair_learning_class =
        contrast_pair_learning_class
      @language_learning.induction_learning_class =
        induction_learning_class
      @language_learning.loser_selector = loser_selector
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'calls phonotactic learning' do
      expect(phonotactic_learning_class).to have_received(:new)
    end
    it 'calls single form learning two times' do
      expect(single_form_learning_class).to have_received(:new)\
        .exactly(2).times
    end
    it 'has PL, SFL, CPL, IL, and SFL learning steps' do
      expect(@result.step_list).to\
        eq [pl_step, sfl_step1, cpl_step, il_obj, sfl_step2]
    end
    it 'calls contrast pair learning one time' do
      expect(contrast_pair_learning_class).to\
        have_received(:new).exactly(1).times
    end
    it 'calls induction learning one time' do
      expect(induction_learning_class).to\
        have_received(:new).exactly(1).times
    end
  end

  context 'when a RuntimeError is raised' do
    # Use StringIO as a test mock for $stderr.
    let(:warn_output) { StringIO.new }
    before(:example) do
      allow(grammar).to receive(:label).and_return('L#err')
      allow(phonotactic_learning_class).to \
        receive(:new).and_return(pl_obj)
      allow(pl_obj).to receive(:run).and_return(pl_step)
      allow(pl_step).to receive(:all_correct?).and_return(false)
      allow(single_form_learning_class).to \
        receive(:new).and_raise(RuntimeError, 'test double error')
      @language_learning =
        OTLearn::LanguageLearning.new(warn_output: warn_output)
      @language_learning.phonotactic_learning_class =
        phonotactic_learning_class
      @language_learning.single_form_learning_class =
        single_form_learning_class
      @language_learning.contrast_pair_learning_class =
        contrast_pair_learning_class
      @language_learning.induction_learning_class =
        induction_learning_class
      @language_learning.loser_selector = loser_selector
      @result = @language_learning.learn(output_list, grammar)
    end
    it 'handles the error and constructs an error step' do
      err_step = @result.step_list[-1]
      expect(err_step.msg).to eq 'Error with L#err: test double error'
    end
    it 'has a PL learning step' do
      expect(@result.step_list).to include(pl_step)
    end
    it 'writes a warning message' do
      expect(warn_output.string).to eq\
        "Error with L#err: test double error\n"
    end
  end
end
