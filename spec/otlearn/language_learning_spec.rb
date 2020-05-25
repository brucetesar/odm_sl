# Author: Bruce Tesar

require 'otlearn/language_learning'

RSpec.describe OTLearn::LanguageLearning do
  let(:output_list){double('output_list')}
  let(:grammar){double('grammar')}
  let(:phonotactic_learning_class){double('phonotactic_learning_class')}
  let(:single_form_learning_class){double('single_form_learning_class')}
  let(:contrast_pair_learning_class){double('contrast_pair_learning_class')}
  let(:induction_learning_class){double('induction_learning_class')}
  let(:loser_selector){double('loser_selector')}
  let(:pl_obj){double('pl_obj')}
  let(:sfl_obj){double('sfl_obj')}
  let(:cpl_obj){double('cpl_obj')}
  let(:il_obj){double('il_obj')}
  before(:each) do
    allow(phonotactic_learning_class).to receive(:new)
    allow(single_form_learning_class).to receive(:new)
    allow(contrast_pair_learning_class).to receive(:new)
    allow(induction_learning_class).to receive(:new)
  end
  
  it "defines a phonotactic step type constant" do
    expect(defined?(OTLearn::LanguageLearning::PHONOTACTIC)).to be_truthy
  end
  it "defines a single form step type constant" do
    expect(defined?(OTLearn::LanguageLearning::SINGLE_FORM)).to be_truthy
  end
  it "defines a contrast pair step type constant" do
    expect(defined?(OTLearn::LanguageLearning::CONTRAST_PAIR)).to be_truthy
  end
  it "defines an induction step type constant" do
    expect(defined?(OTLearn::LanguageLearning::INDUCTION)).to be_truthy
  end
  
  context "given phontactically learnable data" do
    before(:each) do
      allow(phonotactic_learning_class).to \
        receive(:new).with(output_list,grammar, loser_selector: loser_selector).and_return(pl_obj)
      allow(pl_obj).to receive(:all_correct?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new(output_list, grammar,
        phonotactic_learning_class: phonotactic_learning_class,
        single_form_learning_class: single_form_learning_class,
        contrast_pair_learning_class: contrast_pair_learning_class,
        induction_learning_class: induction_learning_class,
        loser_selector: loser_selector)
    end
    it "calls phonotactic learning" do
      expect(phonotactic_learning_class).to \
        have_received(:new).with(output_list,grammar, loser_selector: loser_selector)
    end
    it "has phonotactic learning as its only learning step" do
      expect(@language_learning.step_list).to eq [pl_obj]
    end
    it "does not call single form learning" do
      expect(single_form_learning_class).not_to have_received(:new)
    end
    it "does not call contrast pair learning" do
      expect(contrast_pair_learning_class).not_to have_received(:new)
    end
    it "does not call induction learning" do
      expect(induction_learning_class).not_to have_received(:new)
    end
  end

  context "given single form learnable data" do
    before(:each) do
      allow(phonotactic_learning_class).to \
        receive(:new).with(output_list,grammar, loser_selector: loser_selector).and_return(pl_obj)
      allow(pl_obj).to receive(:all_correct?).and_return(false)
      allow(single_form_learning_class).to \
        receive(:new).with(output_list,grammar, loser_selector: loser_selector).and_return(sfl_obj)
      allow(sfl_obj).to receive(:all_correct?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new(output_list, grammar,
        phonotactic_learning_class: phonotactic_learning_class,
        single_form_learning_class: single_form_learning_class,
        contrast_pair_learning_class: contrast_pair_learning_class,
        induction_learning_class: induction_learning_class,
        loser_selector: loser_selector)
    end
    it "calls phonotactic learning" do
      expect(phonotactic_learning_class).to \
        have_received(:new).with(output_list, grammar, loser_selector:loser_selector)
    end
    it "calls single form learning one time" do
      expect(single_form_learning_class).to have_received(:new).exactly(1).times
    end
    it "has PL and SFL learning steps" do
      expect(@language_learning.step_list).to eq [pl_obj, sfl_obj]
    end
    it "does not call contrast pair learning" do
      expect(contrast_pair_learning_class).not_to have_received(:new)
    end
    it "does not call induction learning" do
      expect(induction_learning_class).not_to have_received(:new)
    end
  end

  context "given single contrast pair learnable data" do
    let(:sfl_obj2){double('sfl_obj2')}
    before(:each) do
      allow(phonotactic_learning_class).to \
        receive(:new).and_return(pl_obj)
      allow(pl_obj).to receive(:all_correct?).and_return(false)
      allow(single_form_learning_class).to \
        receive(:new).and_return(sfl_obj, sfl_obj2)
      allow(sfl_obj).to receive(:all_correct?).and_return(false)
      allow(sfl_obj2).to receive(:test_result)
      allow(sfl_obj2).to receive(:all_correct?).and_return(true)
      allow(contrast_pair_learning_class).to \
        receive(:new).and_return(cpl_obj)
      allow(cpl_obj).to receive(:all_correct?).and_return(false)
      allow(cpl_obj).to receive(:changed?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new(output_list, grammar,
        phonotactic_learning_class: phonotactic_learning_class,
        single_form_learning_class: single_form_learning_class,
        contrast_pair_learning_class: contrast_pair_learning_class,
        induction_learning_class: induction_learning_class,
        loser_selector: loser_selector)
    end
    it "calls phonotactic learning" do
      expect(phonotactic_learning_class).to \
        have_received(:new).with(output_list,grammar,loser_selector:loser_selector)
    end
    it "calls single form learning two times" do
      expect(single_form_learning_class).to have_received(:new).exactly(2).times
    end
    it "has PL, SFL, CPL, and SFL learning steps" do
      expect(@language_learning.step_list).to eq [pl_obj, sfl_obj, cpl_obj, sfl_obj2]
    end
    it "calls contrast pair learning one time" do
      expect(contrast_pair_learning_class).to have_received(:new).exactly(1).times
    end
    it "does not call induction learning" do
      expect(induction_learning_class).not_to have_received(:new)
    end
  end

  context "given single induction step learnable data" do
    let(:sfl_obj2){double('sfl_obj2')}
    before(:each) do
      allow(phonotactic_learning_class).to \
        receive(:new).and_return(pl_obj)
      allow(pl_obj).to receive(:all_correct?).and_return(false)
      allow(single_form_learning_class).to \
        receive(:new).and_return(sfl_obj, sfl_obj2)
      allow(sfl_obj).to receive(:all_correct?).and_return(false)
      allow(sfl_obj2).to receive(:all_correct?).and_return(true)
      allow(contrast_pair_learning_class).to \
        receive(:new).and_return(cpl_obj)
      allow(cpl_obj).to receive(:all_correct?).and_return(false)
      allow(cpl_obj).to receive(:changed?).and_return(false)
      allow(induction_learning_class).to \
        receive(:new).and_return(il_obj)
      allow(il_obj).to receive(:all_correct?).and_return(false)
      allow(il_obj).to receive(:changed?).and_return(true)
      @language_learning = OTLearn::LanguageLearning.new(output_list, grammar,
        phonotactic_learning_class: phonotactic_learning_class,
        single_form_learning_class: single_form_learning_class,
        contrast_pair_learning_class: contrast_pair_learning_class,
        induction_learning_class: induction_learning_class,
        loser_selector: loser_selector)
    end
    it "calls phonotactic learning" do
      expect(phonotactic_learning_class).to \
        have_received(:new).with(output_list,grammar,loser_selector:loser_selector)
    end
    it "calls single form learning two times" do
      expect(single_form_learning_class).to have_received(:new).exactly(2).times
    end
    it "has PL, SFL, CPL, IL, and SFL learning steps" do
      expect(@language_learning.step_list).to eq [pl_obj, sfl_obj, cpl_obj, il_obj, sfl_obj2]
    end
    it "calls contrast pair learning one time" do
      expect(contrast_pair_learning_class).to have_received(:new).exactly(1).times
    end
    it "calls induction learning one time" do
      expect(induction_learning_class).to have_received(:new).exactly(1).times
    end
  end

end # RSpec.describe OTLearn::LanguageLearning
