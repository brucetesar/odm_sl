# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otlearn/mrcd_single'

RSpec.describe OTLearn::MrcdSingle do
  let(:winner) { double('winner') }
  let(:morphword) { double('morphword') }
  let(:param_erc_list) { double('parameter ERC list') }
  let(:erc_list) { double('ERC list') }
  let(:selector) { double('loser selector') }
  let(:loser1) { double('loser1') }
  let(:loser2) { double('loser2') }
  let(:pair_class) { double('wl_pair_class') }
  let(:wl_pair1) { double('wl_pair1') }
  let(:wl_pair2) { double('wl_pair2') }
  before(:each) do
    allow(param_erc_list).to receive(:dup).and_return(erc_list)
    allow(winner).to receive(:morphword).and_return(morphword)
    allow(morphword).to receive(:to_s).and_return('morphword_name')
    allow(wl_pair1).to receive(:label=)
    allow(wl_pair2).to receive(:label=)
  end

  context 'with a word that is already optimal' do
    before(:each) do
      allow(erc_list).to receive(:consistent?).and_return(true)
      allow(selector).to receive(:select_loser).and_return(nil)
      @mrcd_single = OTLearn::MrcdSingle.new(winner, param_erc_list,
                                             selector)
    end
    it 'duplicates the parameter ERC list' do
      expect(param_erc_list).to have_received(:dup)
    end
    it 'creates no added pairs' do
      expect(@mrcd_single.added_pairs.empty?).to be true
    end
    it 'is consistent' do
      expect(@mrcd_single.consistent?).to be true
    end
    it 'calls selector once' do
      expect(selector).to have_received(:select_loser).with(winner,
                                                            erc_list)
    end
  end

  context 'with a word requiring one pair' do
    before(:each) do
      allow(erc_list).to receive(:consistent?).and_return(true)
      allow(erc_list).to receive(:add)
      allow(selector).to receive(:select_loser).and_return(loser1, nil)
      allow(pair_class).to\
        receive(:new).with(winner, loser1).and_return(wl_pair1)
      @mrcd_single = OTLearn::MrcdSingle.new(winner, param_erc_list,
                                             selector,
                                             wl_pair_class: pair_class)
    end
    it 'returns the winner' do
      expect(@mrcd_single.winner).to eq winner
    end
    it 'creates one new winner-loser pair' do
      expect(pair_class).to have_received(:new).with(winner, loser1)
    end
    it 'labels the wl pair with the morphword name' do
      expect(wl_pair1).to have_received(:label=).with('morphword_name')
    end
    it 'returns one added pair' do
      expect(@mrcd_single.added_pairs.size).to eq 1
    end
    it 'returns the created pair' do
      expect(@mrcd_single.added_pairs[0]).to eq wl_pair1
    end
    it 'adds the created pair to the ERC list' do
      expect(erc_list).to have_received(:add).with(wl_pair1)
    end
    it 'is consistent' do
      expect(@mrcd_single.consistent?).to be true
    end
    it 'calls selector twice' do
      expect(selector).to have_received(:select_loser).exactly(2).times
    end
  end

  context 'with a word requiring two pairs' do
    before(:each) do
      allow(erc_list).to receive(:consistent?).and_return(true)
      allow(erc_list).to receive(:add).with(wl_pair1)
      allow(erc_list).to receive(:add).with(wl_pair2)
      allow(selector).to receive(:select_loser).and_return(loser1, loser2, nil)
      allow(pair_class).to\
        receive(:new).with(winner, loser1).and_return(wl_pair1)
      allow(pair_class).to\
        receive(:new).with(winner, loser2).and_return(wl_pair2)
      @mrcd_single = OTLearn::MrcdSingle.new(winner, param_erc_list,
                                             selector,
                                             wl_pair_class: pair_class)
    end
    it 'creates two added pairs' do
      expect(pair_class).to have_received(:new).exactly(2).times
    end
    it 'creates a pair with the winner and the first loser' do
      expect(pair_class).to \
        have_received(:new).with(winner, loser1).exactly(1).times
    end
    it 'creates a pair with the winner and the second loser' do
      expect(pair_class).to \
        have_received(:new).with(winner, loser2).exactly(1).times
    end
    it 'returns two added pairs' do
      expect(@mrcd_single.added_pairs.size).to eq 2
    end
    it 'returns the created pairs' do
      expect(@mrcd_single.added_pairs.member?(wl_pair1)).to be true
      expect(@mrcd_single.added_pairs.member?(wl_pair2)).to be true
    end
    it 'is consistent' do
      expect(@mrcd_single.consistent?).to be true
    end
    it 'calls selector three times' do
      expect(selector).to have_received(:select_loser).exactly(3).times
    end
  end

  context 'with a word reaching inconsistency after one pair' do
    before(:each) do
      # consistency isn't checked until after a winner-loser pair is added
      allow(erc_list).to receive(:consistent?).and_return(false)
      allow(erc_list).to receive(:add)
      allow(selector).to receive(:select_loser).and_return(loser1)
      allow(pair_class).to \
        receive(:new).with(winner, loser1).and_return(wl_pair1)
      @mrcd_single = OTLearn::MrcdSingle.new(winner, param_erc_list,
                                             selector,
                                             wl_pair_class: pair_class)
    end
    it 'creates one new winner-loser pair' do
      expect(pair_class).to have_received(:new).with(winner, loser1)
    end
    it 'returns one added pair' do
      expect(@mrcd_single.added_pairs.size).to eq 1
    end
    it 'returns the created pair' do
      expect(@mrcd_single.added_pairs[0]).to eq wl_pair1
    end
    it 'adds the created pair to the ERC list' do
      expect(erc_list).to have_received(:add).with(wl_pair1)
    end
    it 'is inconsistent' do
      expect(@mrcd_single.consistent?).to be false
    end
    it 'calls selector once' do
      expect(selector).to have_received(:select_loser).exactly(1).time
    end
    it 'calls selector with the winner and the initial erc list' do
      expect(selector).to have_received(:select_loser).with(winner, erc_list)
    end
  end
end
