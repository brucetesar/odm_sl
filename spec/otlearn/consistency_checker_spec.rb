# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/consistency_checker'

RSpec.describe OTLearn::ConsistencyChecker do
  let(:output) { double('output') }
  let(:word) { double('word') }
  let(:grammar) { double('grammar') }
  let(:erc_list) { double('ERC list') }
  let(:mrcd_class) { double('MRCD class') }
  let(:mrcd_result) { double('MRCD result') }
  let(:loser_selector) { double('loser selector') }

  before do
    allow(grammar).to receive(:parse_output).and_return(word)
    allow(grammar).to receive(:erc_list).and_return(erc_list)
    allow(word).to receive(:mismatch_input_to_output!).and_return(word)
    allow(mrcd_class).to receive(:new).and_return(mrcd_result)
    @checker = described_class.new(mrcd_class: mrcd_class)
    @checker.loser_selector = loser_selector
  end

  context 'with words that are consistent' do
    let(:word_list) { double('word_list') }

    before do
      allow(mrcd_result).to receive(:consistent?).and_return(true)
      @result = @checker.consistent?(word_list, grammar)
    end

    it 'calls Mrcd on the word list and ERC list' do
      expect(mrcd_class).to\
        have_received(:new).with(word_list, erc_list, loser_selector)
    end

    it 'indicates consistency' do
      expect(@result).to be true
    end
  end

  context 'with words that are inconsistent' do
    let(:word_list) { double('word_list') }

    before do
      allow(mrcd_result).to receive(:consistent?).and_return(false)
      @result = @checker.consistent?(word_list, grammar)
    end

    it 'calls Mrcd on the word list and ERC list' do
      expect(mrcd_class).to\
        have_received(:new).with(word_list, erc_list, loser_selector)
    end

    it 'indicates inconsistency' do
      expect(@result).to be false
    end
  end

  context 'when outputs are mismatch consistent' do
    before do
      output_list = [output]
      allow(mrcd_result).to receive(:consistent?).and_return(true)
      @result = @checker.mismatch_consistent?(output_list, grammar)
    end

    it 'parses the output into a word' do
      expect(grammar).to have_received(:parse_output).with(output)
    end

    it 'creates a mismatched input word for each output' do
      expect(word).to have_received(:mismatch_input_to_output!)
    end

    it 'calls Mrcd on the word list and ERC list' do
      expect(mrcd_class).to\
        have_received(:new).with([word], erc_list, loser_selector)
    end

    it 'indicates consistency' do
      expect(@result).to be true
    end
  end

  context 'when outputs are mismatch inconsistent' do
    before do
      output_list = [output]
      allow(mrcd_result).to receive(:consistent?).and_return(false)
      @result = @checker.mismatch_consistent?(output_list, grammar)
    end

    it 'parses the output into a word' do
      expect(grammar).to have_received(:parse_output).with(output)
    end

    it 'creates a mismatched input word for each output' do
      expect(word).to have_received(:mismatch_input_to_output!)
    end

    it 'calls Mrcd on the word list and ERC list' do
      expect(mrcd_class).to\
        have_received(:new).with([word], erc_list, loser_selector)
    end

    it 'indicates inconsistency' do
      expect(@result).to be false
    end
  end
end
