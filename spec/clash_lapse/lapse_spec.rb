# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'clash_lapse/lapse'
require 'constraint'
require 'candidate'
require 'output'
require 'sl/syllable'

module ClashLapse
  RSpec.describe Lapse do
    let(:candidate) { instance_double(Candidate, 'candidate') }
    let(:output) { instance_double(Output, 'output') }
    let(:syl0) { instance_double(SL::Syllable, 'syl0') }
    let(:syl1) { instance_double(SL::Syllable, 'syl1') }
    let(:syl2) { instance_double(SL::Syllable, 'syl2') }

    before do
      allow(candidate).to receive(:output).and_return(output)
      @content = described_class.new
    end

    it 'returns the constraint name' do
      expect(@content.name).to eq 'Lapse'
    end

    it 'is a markedness constraint' do
      expect(@content.type).to eq Constraint::MARK
    end

    context 'when a candidate has only one syllable' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:size).and_return(1)
        allow(syl0).to receive(:main_stress?).and_return(true)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate has one unstressed syllable first' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:[]).with(1).and_return(syl1)
        allow(output).to receive(:size).and_return(2)
        allow(syl0).to receive(:unstressed?).and_return(true)
        allow(syl1).to receive(:unstressed?).and_return(false)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate has one unstressed syllable second' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:[]).with(1).and_return(syl1)
        allow(output).to receive(:size).and_return(2)
        allow(syl0).to receive(:unstressed?).and_return(false)
        allow(syl1).to receive(:unstressed?).and_return(true)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate has two unstressed syllables' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:[]).with(1).and_return(syl1)
        allow(output).to receive(:size).and_return(2)
        allow(syl0).to receive(:unstressed?).and_return(true)
        allow(syl1).to receive(:unstressed?).and_return(true)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(candidate)).to eq 1
      end
    end

    context 'when a candidate has two stressed syllables' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:[]).with(1).and_return(syl1)
        allow(output).to receive(:size).and_return(2)
        allow(syl0).to receive(:unstressed?).and_return(false)
        allow(syl1).to receive(:unstressed?).and_return(false)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate has three consecutive unstressed syllables' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:[]).with(1).and_return(syl1)
        allow(output).to receive(:[]).with(2).and_return(syl2)
        allow(output).to receive(:size).and_return(3)
        allow(syl0).to receive(:unstressed?).and_return(true)
        allow(syl1).to receive(:unstressed?).and_return(true)
        allow(syl2).to receive(:unstressed?).and_return(true)
      end

      it 'assesses 2 violations' do
        expect(@content.eval_candidate(candidate)).to eq 2
      end
    end

    context 'when a candidate has non-consecutive unstressed syllables' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:[]).with(1).and_return(syl1)
        allow(output).to receive(:[]).with(2).and_return(syl2)
        allow(output).to receive(:size).and_return(3)
        allow(syl0).to receive(:unstressed?).and_return(true)
        allow(syl1).to receive(:unstressed?).and_return(false)
        allow(syl2).to receive(:unstressed?).and_return(true)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate has second and third unstressed syllables' do
      before do
        allow(output).to receive(:[]).with(0).and_return(syl0)
        allow(output).to receive(:[]).with(1).and_return(syl1)
        allow(output).to receive(:[]).with(2).and_return(syl2)
        allow(output).to receive(:size).and_return(3)
        allow(syl0).to receive(:unstressed?).and_return(false)
        allow(syl1).to receive(:unstressed?).and_return(true)
        allow(syl2).to receive(:unstressed?).and_return(true)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(candidate)).to eq 1
      end
    end
  end
end
