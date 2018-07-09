# Author: Morgan Moyer / Bruce Tesar

require 'otlearn/induction_learning'
require 'otlearn/language_learning'

RSpec.describe OTLearn::InductionLearning, :wip do
  let(:winner_list){double('winner_list')}
  let(:output_list){double('output_list')}
  let(:grammar){double('grammar')}
  let(:prior_result){double('prior_result')}
  let(:language_learner){double('language_learner')}
  let(:fsf){double('fsf')}
  let(:fsf_class){double('FSF_class')}
  let(:otlearn_module){double('otlearn_module')}
  let(:grammar_test_class){double('grammar_test_class')}
  let(:grammar_test){double('grammar_test')}
  before(:each) do
    allow(output_list).to receive(:map).and_return(winner_list)
  end
  
  context "with no failed winners" do
    before(:each) do
      allow(grammar_test_class).to receive(:new).and_return(prior_result, grammar_test)
      allow(prior_result).to receive(:failed_winners).and_return([])
    end
    it "raises a RuntimeError" do
      expect do
        OTLearn::InductionLearning.new(output_list, grammar,
          language_learner,
          grammar_test_class: grammar_test_class)
      end.to raise_error(RuntimeError)
    end
    it "defines a substep constant for fewest set features" do
      expect(defined?(OTLearn::InductionLearning::FEWEST_SET_FEATURES)).to be_truthy
    end
    it "defines a substep constant for max mismatch ranking" do
      expect(defined?(OTLearn::InductionLearning::FEWEST_SET_FEATURES)).to be_truthy
    end
  end
  
  context "with one inconsistent failed winner" do
    let(:failed_winner_1){double('failed_winner_1')}
    # doubles relevant to checking failed winners for consistency
    let(:mrcd_gram){double('mrcd_grammar')}
    let(:mrcd){double('mrcd')}
    before(:each) do
      allow(prior_result).to receive(:failed_winners).and_return([failed_winner_1])
      allow(mrcd_gram).to receive(:consistent?).and_return(false)
      allow(mrcd).to receive(:grammar).and_return(mrcd_gram)
      allow(fsf_class).to receive(:new).and_return(fsf)
      allow(fsf).to receive(:run)
      allow(fsf).to receive(:changed?)
      allow(otlearn_module).to receive(:mismatch_consistency_check).
          with(grammar,[failed_winner_1]).and_return(mrcd)
      allow(grammar_test_class).to receive(:new).and_return(prior_result, grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(true)
    end
    
    context "that allows a feature to be set" do
      before(:each) do
        allow(fsf).to receive(:changed?).and_return(true)
        @induction_learning =
          OTLearn::InductionLearning.new(output_list, grammar,
          language_learner,
          learning_module: otlearn_module,
          grammar_test_class: grammar_test_class,
          fewest_set_features_class: fsf_class)
      end
      it "reports that the grammar has changed" do
        expect(@induction_learning).to be_changed
      end
      it "calls fewest set features" do
        expect(fsf_class).to have_received(:new)
      end
      it "runs a grammar test after learning" do
        expect(grammar_test_class).to have_received(:new).exactly(2).times
      end
      it "gives the grammar test result" do
        expect(@induction_learning.test_result).to eq grammar_test
      end
      it "indicates that all words are handled correctly" do
        expect(@induction_learning).to be_all_correct
      end
      it "has step type INDUCTION" do
        expect(@induction_learning.step_type).to \
          eq OTLearn::LanguageLearning::INDUCTION
      end
    end

    context " that does not allow a feature to be set" do
      before(:each) do
        allow(fsf).to receive(:changed?).and_return(false)
        @induction_learning =
          OTLearn::InductionLearning.new(output_list, grammar,
          language_learner,
          learning_module: otlearn_module,
          grammar_test_class: grammar_test_class,
          fewest_set_features_class: fsf_class)
      end
      it "reports that the grammar has not changed" do
        expect(@induction_learning).not_to be_changed
      end
      it "calls fewest set features" do
        expect(fsf_class).to have_received(:new)
      end
      it "runs a grammar test after learning" do
        expect(grammar_test_class).to have_received(:new).exactly(2).times
      end
      it "gives the grammar test result" do
        expect(@induction_learning.test_result).to eq grammar_test
      end
      it "indicates that all words are handled correctly" do
        expect(@induction_learning).to be_all_correct
      end
    end
  end

end # RSpec.describe OTLearn::InductionLearning
