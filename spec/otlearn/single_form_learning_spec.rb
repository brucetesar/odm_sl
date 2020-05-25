# Author: Bruce Tesar

require 'otlearn/single_form_learning'
require 'otlearn/language_learning'
require 'otlearn/grammar_test'

RSpec.describe OTLearn::SingleFormLearning do
  let(:win1){double('winner 1')}
  let(:out1){double('output 1')}
  let(:grammar){double('grammar')}
  let(:grammar_test_class){double('grammar_test_class')}
  let(:grammar_test){instance_double(OTLearn::GrammarTest)}
  let(:otlearn_module){double('OTLearn module')}
  let(:consistency_result){double('consistency_result')}
  let(:cr_grammar){double('cr_grammar')}
  let(:loser_selector){double('loser_selector')}
  let(:mrcd_result){double('mrcd_result')}
  before(:example) do
    allow(win1).to receive(:match_input_to_output!)
  end
  
  context "with one correct winner" do
    let(:winner_list){[win1]}
    let(:output_list){[out1]}
    before(:example) do
      allow(output_list).to receive(:map).and_return(winner_list)
      allow(grammar).to receive(:parse_output).with(out1).and_return(win1)
      allow(otlearn_module).to receive(:mismatch_consistency_check)
      allow(grammar_test_class).to receive(:new).with([out1], grammar).and_return(grammar_test)
      allow(grammar_test_class).to receive(:new).with(output_list, grammar).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
      @single_form_learning = OTLearn::SingleFormLearning.new(output_list,
        grammar, learning_module: otlearn_module,
        grammar_test_class: grammar_test_class,
        loser_selector: loser_selector)
    end
    it "does not change the grammar" do
      expect(@single_form_learning).not_to be_changed
    end
    it "returns an output list with one output" do
      expect(@single_form_learning.output_list).to eq output_list
    end
    it "returns the grammar" do
      expect(@single_form_learning.grammar).to eq grammar
    end
    it "tests the winner once during learning, all winners afterward" do
      expect(grammar_test_class).to have_received(:new).exactly(2).times
    end    
    it "does not perform a mismatch consistency check" do
      expect(otlearn_module).not_to have_received(:mismatch_consistency_check)
    end
    it "gives the grammar test result" do
      expect(@single_form_learning.test_result).to eq grammar_test
    end
    it "indicates that all words are handled correctly" do
      expect(@single_form_learning.all_correct?).to be true
    end
    it "has step type SINGLE_FORM" do
      expect(@single_form_learning.step_type).to \
        eq OTLearn::LanguageLearning::SINGLE_FORM
    end
  end
  
  context "with one incorrect winner with a settable feature and other unsettable features" do
    let(:winner_list){[win1]}
    let(:output_list){[out1]}
    before(:example) do
      allow(output_list).to receive(:map).and_return(winner_list)
      allow(grammar).to receive(:parse_output).with(out1).and_return(win1)
      allow(otlearn_module).to receive(:mismatch_consistency_check).and_return(consistency_result)
      allow(otlearn_module).to receive(:set_uf_values).with([win1], grammar).and_return(["feature1"],[])
      allow(otlearn_module).to receive(:new_rank_info_from_feature).with(grammar,winner_list,"feature1",loser_selector: loser_selector)
      allow(otlearn_module).to receive(:ranking_learning).and_return(mrcd_result)
      allow(mrcd_result).to receive(:any_change?).and_return(false)
      allow(grammar_test_class).to receive(:new).and_return(grammar_test)
      allow(grammar_test_class).to receive(:new).with([out1], grammar).and_return(grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      allow(consistency_result).to receive(:grammar).and_return(cr_grammar)
      allow(cr_grammar).to receive(:consistent?).and_return(false, false)
      @single_form_learning = OTLearn::SingleFormLearning.new(output_list,
        grammar, learning_module: otlearn_module,
        grammar_test_class: grammar_test_class,
        loser_selector: loser_selector)
    end
    it "changes the grammar" do
      expect(@single_form_learning).to be_changed
    end
    it "returns an output list with one output" do
      expect(@single_form_learning.output_list).to eq output_list
    end
    it "returns the grammar" do
      expect(@single_form_learning.grammar).to eq grammar
    end
    it "performs two mismatch consistency checks" do
      expect(otlearn_module).to have_received(:mismatch_consistency_check).with(grammar,[win1]).exactly(2).times
    end
    it "calls set_uf_features twice" do
      expect(otlearn_module).to have_received(:set_uf_values).with([win1],grammar).exactly(2).times
    end
    it "checks for new ranking information on the set feature once" do
      expect(otlearn_module).to have_received(:new_rank_info_from_feature).with(grammar,winner_list,"feature1",loser_selector:loser_selector).exactly(1).times
    end
    it "tests the winner twice during learning, all winners afterward" do
      expect(grammar_test_class).to have_received(:new).exactly(3).times
    end    
    it "gives the grammar test result" do
      expect(@single_form_learning.test_result).to eq grammar_test
    end
    it "indicates that not all words are handled correctly" do
      expect(@single_form_learning.all_correct?).to be false
    end
  end
  
end # RSpec.describe OTLearn::SingleFormLearning
