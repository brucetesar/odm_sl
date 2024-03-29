# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/mmr_substep'
require 'otlearn/otlearn'

RSpec.describe OTLearn::MmrSubstep do
  let(:new_pairs) { double('new_pairs') }
  let(:failed_winner) { double('failed_winner') }
  let(:change_flag) { double('change_flag') }
  let(:failed_winner_list) { [failed_winner] }

  before do
    @substep = described_class.new(new_pairs, failed_winner, change_flag,
                                   failed_winner_list)
  end

  it 'indicates a subtype of MaxMismatchRanking' do
    expect(@substep.subtype).to eq OTLearn::MAX_MISMATCH_RANKING
  end

  it 'returns the list of newly added WL pairs' do
    expect(@substep.newly_added_wl_pairs).to eq new_pairs
  end

  it 'returns the failed winner' do
    expect(@substep.failed_winner).to eq failed_winner
  end

  it 'returns the grammar change flag' do
    expect(@substep.changed?).to eq change_flag
  end

  it 'returns a list of all failed winners' do
    expect(@substep.failed_winner_list).to contain_exactly(failed_winner)
  end
end
