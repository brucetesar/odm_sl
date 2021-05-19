# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/grammar_test'

RSpec.describe OTLearn::GrammarTest do
  let(:grammar) { double { 'grammar' } }
  let(:system) { double('system') }
  let(:selector) { double { 'loser_selector' } }
  let(:output_opt) { double('output_opt') }
  let(:winner_opt) { double('winner_opt') }
  let(:output_nopt) { double('output_nopt') }
  let(:winner_nopt) { double('winner_nopt') }
  let(:loser) { double('loser') }

  before do
    allow(grammar).to receive(:system).and_return(system)
    allow(grammar).to receive(:dup).and_return(grammar)
    allow(grammar).to receive(:freeze)
    allow(grammar).to receive(:erc_list).and_return('ERCs')
    allow(grammar).to\
      receive(:parse_output).with(output_opt).and_return(winner_opt)
    allow(grammar).to\
      receive(:parse_output).with(output_nopt).and_return(winner_nopt)
    allow(winner_opt).to receive(:freeze)
    allow(winner_nopt).to receive(:freeze)
    allow(winner_opt).to receive(:mismatch_input_to_output!)
    allow(winner_nopt).to receive(:mismatch_input_to_output!)
    allow(selector).to\
      receive(:select_loser).with(winner_opt, 'ERCs').and_return(nil)
    allow(selector).to\
      receive(:select_loser).with(winner_nopt, 'ERCs').and_return(loser)
    @grammar_test = described_class.new
    @grammar_test.loser_selector = selector
  end

  context 'with one optimal winner' do
    let(:output_list) { [output_opt] }

    before do
      @result = @grammar_test.run(output_list, grammar)
    end

    it 'returns a list with that winner for success winners' do
      expect(@result.success_winners).to eq [winner_opt]
    end

    it 'returns an empty list for failed winners' do
      expect(@result.failed_winners).to be_empty
    end

    it 'reports that all winners are successful' do
      expect(@result.all_correct?).to be true
    end
  end

  context 'with one non-optimal winner' do
    let(:output_list) { [output_nopt] }

    before do
      @result = @grammar_test.run(output_list, grammar)
    end

    it 'returns an empty list for success winners' do
      expect(@result.success_winners).to be_empty
    end

    it 'returns a list with that winner for failed winners' do
      expect(@result.failed_winners).to eq [winner_nopt]
    end

    it 'reports that not all winners are successful' do
      expect(@result.all_correct?).to be false
    end
  end

  context 'with one optimal and one non-optimal winner' do
    let(:output_list) { [output_opt, output_nopt] }

    before do
      @result = @grammar_test.run(output_list, grammar)
    end

    it 'returns a list with the opt winner for success winners' do
      expect(@result.success_winners).to eq [winner_opt]
    end

    it 'returns a list with the non-opt winner for failed winners' do
      expect(@result.failed_winners).to eq [winner_nopt]
    end

    it 'reports that not all winners are successful' do
      expect(@result.all_correct?).to be false
    end
  end
end
