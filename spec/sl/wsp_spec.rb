# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/wsp'
require 'constraint'
require 'sl/syllable'
require 'candidate'

module SL
  RSpec.describe Wsp do
    let(:candidate) { instance_double(Candidate, 'candidate') }
    let(:syl1) { instance_double(Syllable, 'syl1') }
    let(:syl2) { instance_double(Syllable, 'syl2') }
    let(:syl3) { instance_double(Syllable, 'syl3') }

    before do
      @content = described_class.new
    end

    it 'returns the name WSP' do
      expect(@content.name).to eq 'WSP'
    end

    it 'is a markedness constraint' do
      expect(@content.type).to eq Constraint::MARK
    end

    context 'when a candidate has one long unstressed syllable' do
      before do
        allow(syl1).to receive(:long?).and_return(true)
        allow(syl1).to receive(:unstressed?).and_return(true)
        output = [syl1]
        allow(candidate).to receive(:output).and_return(output)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(candidate)).to eq 1
      end
    end

    context 'when a candidate has one short unstressed syllable' do
      before do
        allow(syl1).to receive(:long?).and_return(false)
        allow(syl1).to receive(:unstressed?).and_return(true)
        output = [syl1]
        allow(candidate).to receive(:output).and_return(output)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate has three syllables,' \
            ' two of which are long/unstressed' do
      before do
        allow(syl1).to receive(:long?).and_return(true)
        allow(syl1).to receive(:unstressed?).and_return(true)
        allow(syl2).to receive(:long?).and_return(false)
        allow(syl2).to receive(:unstressed?).and_return(false)
        allow(syl3).to receive(:long?).and_return(true)
        allow(syl3).to receive(:unstressed?).and_return(true)
        output = [syl1, syl2, syl3]
        allow(candidate).to receive(:output).and_return(output)
      end

      it 'assesses 2 violations' do
        expect(@content.eval_candidate(candidate)).to eq 2
      end
    end
  end
end
