# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/mrcd'

RSpec.describe OTLearn::Mrcd do
  let(:param_erc_list) { double('param_erc_list') }
  let(:prior_ercs) { double('prior_ercs') }
  let(:erc_list) { double('erc_list') }
  let(:selector) { double('selector') }
  let(:single_mrcd_class) { double('single MRCD class') }

  before do
    allow(param_erc_list).to receive(:dup).and_return(prior_ercs, erc_list)
    allow(prior_ercs).to receive(:freeze).and_return(prior_ercs)
    allow(erc_list).to receive(:freeze).and_return(erc_list)
  end

  context 'with an empty word list' do
    before do
      @word_list = []
      allow(prior_ercs).to receive(:empty?).and_return(true)
      allow(erc_list).to receive(:empty?).and_return(true)
      allow(erc_list).to receive(:consistent?).and_return(true)
      @mrcd = described_class.new(@word_list, param_erc_list, selector,
                                  single_mrcd_class: single_mrcd_class)
    end

    it 'does not have any changes to the ranking information' do
      expect(@mrcd.any_change?).not_to be true
    end

    it 'returns an empty new pairs list' do
      expect(@mrcd.added_pairs).to be_empty
    end

    it 'returns an empty prior ercs list' do
      expect(@mrcd.prior_ercs).to be_empty
    end

    it 'returns an empty total ERC list' do
      expect(@mrcd.erc_list).to be_empty
    end

    it 'freezes the prior ercs list' do
      expect(@mrcd.prior_ercs).to have_received(:freeze)
    end

    it 'freezes the added pairs list' do
      expect(@mrcd.added_pairs).to be_frozen
    end

    it 'freezes the erc list' do
      expect(@mrcd.erc_list).to have_received(:freeze)
    end
  end

  context 'with a single winner producing no new pairs' do
    let(:winner) { double('winner') }
    let(:mrcd_single) { double('mrcd_single') }

    before do
      @word_list = [winner]
      allow(single_mrcd_class).to receive(:new).and_return(mrcd_single)
      allow(mrcd_single).to receive(:added_pairs).and_return([])
      allow(erc_list).to receive(:consistent?).and_return(true)
      @mrcd = described_class.new(@word_list, param_erc_list, selector,
                                  single_mrcd_class: single_mrcd_class)
    end

    it 'does not have any changes to the ranking information' do
      expect(@mrcd.any_change?).not_to be true
    end

    it 'returns no new pairs' do
      expect(@mrcd.added_pairs).to be_empty
    end

    it 'creates one mrcd_single object' do
      expect(single_mrcd_class).to have_received(:new).exactly(1).times
    end
  end

  context 'with a single winner producing one new pair' do
    let(:winner) { double('winner') }
    let(:mrcd_single1) { double('mrcd_single1') }
    let(:mrcd_single2) { double('mrcd_single2') }
    let(:new_pair) { double('new WL pair') }

    before do
      @word_list = [winner]
      allow(single_mrcd_class).to\
        receive(:new).and_return(mrcd_single1, mrcd_single2)
      allow(mrcd_single1).to receive(:added_pairs).and_return([new_pair])
      allow(mrcd_single2).to receive(:added_pairs).and_return([])
      allow(erc_list).to receive(:consistent?).and_return(true)
      allow(erc_list).to receive(:add).with(new_pair)
      @mrcd = described_class.new(@word_list, param_erc_list, selector,
                                  single_mrcd_class: single_mrcd_class)
    end

    it 'has changes to the ranking information' do
      expect(@mrcd.any_change?).to be true
    end

    it 'returns one new pair' do
      expect(@mrcd.added_pairs.size).to eq 1
    end
    # Two mrcd objects, one for each pass through the word list (with 1 winner)

    it 'creates two mrcd_single objects' do
      expect(single_mrcd_class).to have_received(:new).exactly(2).times
    end
  end

  # If any changes occur on the first pass, it should make a second
  # pass through all of the winners.
  context 'with 3 winners producing 2 new pairs' do
    let(:winner1) { double('winner1') }
    let(:winner2) { double('winner2') }
    let(:winner3) { double('winner3') }
    let(:mrcd_single1) { double('mrcd_single1') }
    let(:mrcd_single2) { double('mrcd_single2') }
    let(:mrcd_single3) { double('mrcd_single3') }
    let(:mrcd_single4) { double('mrcd_single4') }
    let(:mrcd_single5) { double('mrcd_single5') }
    let(:mrcd_single6) { double('mrcd_single6') }
    let(:new_pair1) { double('new WL pair 1') }
    let(:new_pair2) { double('new WL pair 2') }

    before do
      @word_list = [winner1, winner2, winner3]
      allow(single_mrcd_class).to\
        receive(:new).and_return(mrcd_single1, mrcd_single2, mrcd_single3,
                                 mrcd_single4, mrcd_single5, mrcd_single6)
      allow(mrcd_single1).to receive(:added_pairs).and_return([new_pair1])
      allow(mrcd_single2).to receive(:added_pairs).and_return([])
      allow(mrcd_single3).to receive(:added_pairs).and_return([new_pair2])
      allow(mrcd_single4).to receive(:added_pairs).and_return([])
      allow(mrcd_single5).to receive(:added_pairs).and_return([])
      allow(mrcd_single6).to receive(:added_pairs).and_return([])
      allow(erc_list).to receive(:consistent?).and_return(true)
      allow(erc_list).to receive(:add).with(new_pair1)
      allow(erc_list).to receive(:add).with(new_pair2)
      @mrcd = described_class.new(@word_list, param_erc_list, selector,
                                  single_mrcd_class: single_mrcd_class)
    end

    it 'has changes to the ranking information' do
      expect(@mrcd.any_change?).to be true
    end

    it 'is consistent' do
      expect(@mrcd.consistent?).to be true
    end

    it 'returns 2 new pairs' do
      expect(@mrcd.added_pairs.size).to eq 2
    end
    # 6 mrcd objects, 3 for each pass through the word list (with 3 winners)

    it 'creates 6 mrcd_single objects' do
      expect(single_mrcd_class).to have_received(:new).exactly(6).times
    end
  end

  # When a winner leads to inconsistency, MRCD should halt immediately,
  # without processing the rest of the winners, or making another pass.
  context 'with 3 winners, the second yielding inconsistency' do
    let(:winner1) { double('winner1') }
    let(:winner2) { double('winner2') }
    let(:winner3) { double('winner3') }
    let(:mrcd_single1) { double('mrcd_single1') }
    let(:mrcd_single2) { double('mrcd_single2') }
    let(:new_pair1) { double('new WL pair 1') }

    before do
      @word_list = [winner1, winner2, winner3]
      allow(single_mrcd_class).to receive(:new).and_return(mrcd_single1,
                                                           mrcd_single2)
      allow(mrcd_single1).to receive(:added_pairs).and_return([new_pair1])
      allow(mrcd_single2).to receive(:added_pairs).and_return([])
      allow(erc_list).to\
        receive(:consistent?).and_return(true, false, false)
      allow(erc_list).to receive(:add).with(new_pair1)
      @mrcd = described_class.new(@word_list, param_erc_list, selector,
                                  single_mrcd_class: single_mrcd_class)
    end

    it 'has changes to the ranking information' do
      expect(@mrcd.any_change?).to be true
    end

    it 'is inconsistent' do
      expect(@mrcd.consistent?).to be false
    end

    it 'returns 1 new pair' do
      expect(@mrcd.added_pairs.size).to eq 1
    end
    # 2 mrcd objects, for first two winners of one pass
    # Verifies that MRCD terminates as soon as inconsistency occurs.

    it 'creates 2 mrcd_single objects' do
      expect(single_mrcd_class).to have_received(:new).exactly(2).times
    end
  end
end
