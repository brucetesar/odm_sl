# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/grammar_test_result'

RSpec.describe 'OTLearn::GrammarTestResult' do
  let(:failed_winners) { [] }
  let(:success_winners) { [] }
  let(:grammar) { double('grammar') }
  let(:win1) { double('winner1') }
  let(:win2) { double('winner2') }
  let(:out1) { double('output1') }
  let(:out2) { double('output2') }
  before(:example) do
    allow(win1).to receive(:output).and_return(out1)
    allow(win2).to receive(:output).and_return(out2)
  end
  context 'with an empty failed winner list' do
    before(:example) do
      success_winners << win1 << win2
      @result =
        OTLearn::GrammarTestResult.new(failed_winners, success_winners,
                                       grammar)
    end
    it 'returns the grammar' do
      expect(@result.grammar).to eq grammar
    end
    it 'returns the failed winners' do
      expect(@result.failed_winners).to eq failed_winners
    end
    it 'returns the success winners' do
      expect(@result.success_winners).to eq success_winners
    end
    it 'identifies that all winners are correct' do
      expect(@result.all_correct?).to be true
    end
    it 'returns the failed outputs' do
      expect(@result.failed_outputs).to be_empty
    end
    it 'returns the success outputs' do
      expect(@result.success_outputs).to contain_exactly(out1, out2)
    end
  end
  context 'with failed winners' do
    before(:example) do
      failed_winners << win1
      success_winners << win2
      @result =
        OTLearn::GrammarTestResult.new(failed_winners, success_winners,
                                       grammar)
    end
    it 'identifies that not all winners are correct' do
      expect(@result.all_correct?).to be false
    end
    it 'returns the failed outputs' do
      expect(@result.failed_outputs).to contain_exactly(out1)
    end
    it 'returns the success outputs' do
      expect(@result.success_outputs).to contain_exactly(out2)
    end
  end
end
