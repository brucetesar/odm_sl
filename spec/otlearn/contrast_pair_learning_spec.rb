# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/contrast_pair_learning'

RSpec.describe 'OTLearn::ContrastPairLearning' do
  let(:winner_list) { double('winner_list') }
  let(:output_list) { double('output_list') }
  let(:grammar) { double('grammar') }
  let(:cp_gen_class) { double('cp_generator_class') }
  let(:cp_gen) { double('cp_generator') }
  let(:cp_enum) { double('cp_enumerator') }
  let(:first_cp) { double('first_cp') }
  let(:second_cp) { double('second_cp') }
  let(:grammar_tester) { double('grammar_tester') }
  let(:test_result) { double('test_result') }
  let(:para_erc_learner) { double('para_erc_learner') }
  let(:feature_learner) { double('feature_learner') }
  before(:example) do
    allow(output_list).to receive(:map).and_return(winner_list)
    allow(para_erc_learner).to receive(:run)
    allow(cp_gen_class).to receive(:new).and_return(cp_gen)
    allow(cp_gen).to receive(:outputs=).with(output_list)
    allow(cp_gen).to receive(:grammar=).with(grammar)
    allow(cp_gen).to receive(:grammar_tester=).with(grammar_tester)
    allow(cp_gen).to receive(:to_enum).and_return cp_enum
    allow(grammar_tester).to receive(:run).and_return(test_result)
    allow(test_result).to receive(:all_correct?).and_return(false)
  end

  context 'with first pair informative' do
    before(:example) do
      allow(cp_enum).to receive(:next).and_return(first_cp)
      allow(feature_learner).to\
        receive(:run).with(first_cp, grammar).and_return(['feat1'])
      cp_learner =
        OTLearn::ContrastPairLearning.new(cp_gen_class: cp_gen_class)
      cp_learner.para_erc_learner = para_erc_learner
      cp_learner.feature_learner = feature_learner
      cp_learner.grammar_tester = grammar_tester
      @cp_step = cp_learner.run(output_list, grammar)
    end
    it 'returns the first pair' do
      expect(@cp_step.contrast_pair).to eq first_cp
    end
    it 'checks for ranking information wih feat1' do
      expect(para_erc_learner).to have_received(:run)\
        .with('feat1', grammar, output_list).exactly(1).times
    end
    it 'changes the grammar' do
      expect(@cp_step).to be_changed
    end
    it 'runs a grammar test after learning' do
      expect(grammar_tester).to have_received(:run).exactly(1).times
    end
    it 'gives the grammar test result' do
      expect(@cp_step.test_result).to eq test_result
    end
    it 'indicates that not all words are handled correctly' do
      expect(@cp_step).not_to be_all_correct
    end
    it 'has step type CONTRAST_PAIR' do
      expect(@cp_step.step_type).to eq OTLearn::CONTRAST_PAIR
    end
  end

  context 'with one uninformative pair' do
    before(:example) do
      allow(cp_enum).to \
        receive(:next).and_return(first_cp).and_raise(StopIteration)
      allow(feature_learner).to\
        receive(:run).with(first_cp, grammar).and_return([])
      cp_learner =
        OTLearn::ContrastPairLearning.new(cp_gen_class: cp_gen_class)
      cp_learner.para_erc_learner = para_erc_learner
      cp_learner.feature_learner = feature_learner
      cp_learner.grammar_tester = grammar_tester
      @cp_step = cp_learner.run(output_list, grammar)
    end
    it 'returns no contrast pair' do
      expect(@cp_step.contrast_pair).to be_nil
    end
    it 'does not check for ranking information' do
      expect(para_erc_learner).not_to have_received(:run)
    end
    it 'does not change the grammar' do
      expect(@cp_step).not_to be_changed
    end
    it 'runs a grammar test after learning' do
      expect(grammar_tester).to have_received(:run).exactly(1).times
    end
    it 'gives the grammar test result' do
      expect(@cp_step.test_result).to eq test_result
    end
    it 'indicates that not all words are handled correctly' do
      expect(@cp_step).not_to be_all_correct
    end
  end

  context 'with the second pair informative' do
    before(:example) do
      allow(cp_enum).to receive(:next).and_return(second_cp)
      allow(feature_learner).to\
        receive(:run).with(second_cp, grammar).and_return(['feat1'])
      cp_learner =
        OTLearn::ContrastPairLearning.new(cp_gen_class: cp_gen_class)
      cp_learner.para_erc_learner = para_erc_learner
      cp_learner.feature_learner = feature_learner
      cp_learner.grammar_tester = grammar_tester
      @cp_step = cp_learner.run(output_list, grammar)
    end
    it 'returns the second pair' do
      expect(@cp_step.contrast_pair).to eq second_cp
    end
    it 'checks for ranking information wih feat1' do
      expect(para_erc_learner).to have_received(:run)\
        .with('feat1', grammar, output_list).exactly(1).times
    end
    it 'changes the grammar' do
      expect(@cp_step).to be_changed
    end
    it 'runs a grammar test after learning' do
      expect(grammar_tester).to have_received(:run).exactly(1).times
    end
    it 'gives the grammar test result' do
      expect(@cp_step.test_result).to eq test_result
    end
    it 'indicates that not all words are handled correctly' do
      expect(@cp_step).not_to be_all_correct
    end
  end
end
