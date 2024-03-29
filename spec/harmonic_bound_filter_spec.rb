# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'harmonic_bound_filter'

RSpec.describe HarmonicBoundFilter do
  let(:erc_list_class) { double('erc_list_class') }
  let(:cand1) { double('candidate1') }
  let(:cand2) { double('candidate2') }
  let(:erclist1) { instance_double(ErcList, 'erc_list_1') }
  let(:erclist2) { instance_double(ErcList, 'erc_list_2') }

  context 'with one candidate' do
    before do
      comp = [cand1]
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand1, comp).and_return(erclist1)
      allow(erclist1).to receive(:consistent?).and_return(true)
      hb_filter = described_class.new(erc_list_class: erc_list_class)
      @filtered_list = hb_filter.remove_collectively_bound(comp)
    end

    it 'returns that candidate' do
      expect(@filtered_list).to eq [cand1]
    end
  end

  context 'with 2 candidates' do
    before do
      @comp = [cand1, cand2]
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand1, @comp).and_return(erclist1)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(cand2, @comp).and_return(erclist2)
    end

    context 'when both are non-HB' do
      before do
        allow(erclist1).to receive(:consistent?).and_return(true)
        allow(erclist2).to receive(:consistent?).and_return(true)
        hb_filter = described_class.new(erc_list_class: erc_list_class)
        @filtered_list = hb_filter.remove_collectively_bound(@comp)
      end

      it 'returns both candidates' do
        expect(@filtered_list).to eq [cand1, cand2]
      end
    end

    context 'when one non-HB and one HB' do
      before do
        allow(erclist1).to receive(:consistent?).and_return(true)
        allow(erclist2).to receive(:consistent?).and_return(false)
        hb_filter = described_class.new(erc_list_class: erc_list_class)
        @filtered_list = hb_filter.remove_collectively_bound(@comp)
      end

      it 'returns only the non-HB candidate' do
        expect(@filtered_list).to eq [cand1]
      end
    end

    context 'when one HB and one non-HB' do
      before do
        allow(erclist1).to receive(:consistent?).and_return(false)
        allow(erclist2).to receive(:consistent?).and_return(true)
        hb_filter = described_class.new(erc_list_class: erc_list_class)
        @filtered_list = hb_filter.remove_collectively_bound(@comp)
      end

      it 'returns only the non-HB candidate' do
        expect(@filtered_list).to eq [cand2]
      end
    end
  end
end
