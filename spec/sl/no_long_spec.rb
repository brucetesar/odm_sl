# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/no_long'
require 'sl/syllable'
require 'candidate'

module SL
  RSpec.describe NoLong do
    let(:candidate) { instance_double(Candidate, 'candidate') }
    let(:syl1) { instance_double(Syllable, 'syl1') }
    let(:syl2) { instance_double(Syllable, 'syl2') }
    let(:syl3) { instance_double(Syllable, 'syl3') }

    before do
      @no_long = described_class.new
    end

    it 'returns the name NoLong' do
      expect(@no_long.name).to eq 'NoLong'
    end

    it 'is a markedness constraint' do
      expect(@no_long.type).to eq Constraint::MARK
    end

    context 'when a candidate has one short and one long syllable' do
      before do
        allow(syl1).to receive(:long?).and_return(false)
        allow(syl2).to receive(:long?).and_return(true)
        output = [syl1, syl2]
        allow(candidate).to receive(:output).and_return(output)
      end

      it 'assesses 1 violation' do
        expect(@no_long.eval_candidate(candidate)).to eq 1
      end
    end

    context 'when a candidate has one short syllable' do
      before do
        allow(syl1).to receive(:long?).and_return(false)
        output = [syl1]
        allow(candidate).to receive(:output).and_return(output)
      end

      it 'assesses 0 violations' do
        expect(@no_long.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate has three syllables long-short-long' do
      before do
        allow(syl1).to receive(:long?).and_return(true)
        allow(syl2).to receive(:long?).and_return(false)
        allow(syl3).to receive(:long?).and_return(true)
        output = [syl1, syl2, syl3]
        allow(candidate).to receive(:output).and_return(output)
      end

      it 'assesses 2 violations' do
        expect(@no_long.eval_candidate(candidate)).to eq 2
      end
    end
  end
end
