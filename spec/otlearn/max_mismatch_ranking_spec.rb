# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'rspec'
require 'otlearn/max_mismatch_ranking'
require 'stringio'

RSpec.describe OTLearn::MaxMismatchRanking do
  let(:failed_winner) { double('failed_winner') }
  let(:failed_winner_list) { [failed_winner] }
  let(:mismatch) { double('mismatch') }
  let(:grammar) { double('grammar') }
  let(:erc_learner) { double('erc_learner') }
  let(:mrcd_result) { double('mrcd_result') }
  # Use StringIO as a test mock for $stdout.
  let(:msg_output) { StringIO.new }

  before do
    allow(failed_winner).to receive(:output)
    allow(grammar).to receive(:parse_output).and_return(mismatch)
    allow(mismatch).to receive(:mismatch_input_to_output!)
    allow(erc_learner).to receive(:run).and_return(mrcd_result)
  end

  context 'with a consistent failed winner yielding new ranking info' do
    let(:new_pair) { double('new_pair') }

    before do
      allow(mrcd_result).to receive(:any_change?).and_return(true)
      allow(mrcd_result).to receive(:added_pairs).and_return([new_pair])
      @max_mismatch_ranking = described_class.new(msg_output: msg_output)
      @max_mismatch_ranking.erc_learner = erc_learner
      @mmr_step = @max_mismatch_ranking.run(failed_winner_list, grammar)
    end

    it 'returns a list with the newpair' do
      expect(@mmr_step.newly_added_wl_pairs).to eq([new_pair])
    end

    it 'indicates a change has occurred' do
      expect(@mmr_step.changed?).to be true
    end

    it 'runs the ERC learner' do
      expect(erc_learner).to have_received(:run).with([mismatch], grammar)
    end

    it 'determines the failed winner' do
      expect(@mmr_step.failed_winner).to eq(mismatch)
    end

    it 'does not write a console message' do
      expect(msg_output.string).to eq ''
    end
  end

  context 'with a consistent failed winner yielding no new ranking info' do
    before do
      allow(mrcd_result).to receive(:any_change?).and_return(false)
      allow(mrcd_result).to receive(:added_pairs).and_return([])
      @max_mismatch_ranking = described_class.new(msg_output: msg_output)
      @max_mismatch_ranking.erc_learner = erc_learner
      @mmr_step = @max_mismatch_ranking.run(failed_winner_list, grammar)
    end

    it 'returns an empty list of new pairs' do
      expect(@mmr_step.newly_added_wl_pairs).to be_empty
    end

    it 'indicates no change has occurred' do
      expect(@mmr_step.changed?).to be false
    end

    it 'runs the ERC learner' do
      expect(erc_learner).to have_received(:run).with([mismatch], grammar)
    end

    it 'determines the failed winner' do
      expect(@mmr_step.failed_winner).to eq(mismatch)
    end

    it 'writes a console message' do
      expect(msg_output.string).to eq 'MMR: A failed consistent winner' \
        " did not provide new ranking information.\n"
    end
  end
end
