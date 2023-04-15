# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'multi_stress/stress_left'
require 'candidate'
require 'sl/syllable'
require 'constraint'

RSpec.describe MultiStress::StressLeft do
  let(:candidate) { instance_double(Candidate, 'candidate') }
  let(:syl1) { instance_double(SL::Syllable, 'syl1') }
  let(:syl2) { instance_double(SL::Syllable, 'syl2') }
  let(:syl3) { instance_double(SL::Syllable, 'syl3') }

  before do
    @content = described_class.new
  end

  it 'returns the name SL' do
    expect(@content.name).to eq 'SL'
  end

  it 'is a markedness constraint' do
    expect(@content.type).to eq Constraint::MARK
  end

  context 'when a 2-syl candidate' do
    before do
      # output is expected to implement the Enumerable interface,
      # accepting iterators like #each and #each_with_index.
      output = [syl1, syl2]
      allow(candidate).to receive(:output).and_return(output)
    end

    context 'with initial stress only' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(true)
        allow(syl2).to receive(:main_stress?).and_return(false)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'with final stress only' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(false)
        allow(syl2).to receive(:main_stress?).and_return(true)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(candidate)).to eq 1
      end
    end

    context 'with both syllables stressed' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(true)
        allow(syl2).to receive(:main_stress?).and_return(true)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(candidate)).to eq 1
      end
    end
  end

  context 'when a 3-syl candidate' do
    before do
      output = [syl1, syl2, syl3]
      allow(candidate).to receive(:output).and_return(output)
    end

    context 'with initial stress only' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(true)
        allow(syl2).to receive(:main_stress?).and_return(false)
        allow(syl3).to receive(:main_stress?).and_return(false)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'with final stress only' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(false)
        allow(syl2).to receive(:main_stress?).and_return(false)
        allow(syl3).to receive(:main_stress?).and_return(true)
      end

      it 'assesses 2 violations' do
        expect(@content.eval_candidate(candidate)).to eq 2
      end
    end

    context 'with penultimate stress only' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(false)
        allow(syl2).to receive(:main_stress?).and_return(true)
        allow(syl3).to receive(:main_stress?).and_return(false)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(candidate)).to eq 1
      end
    end

    context 'with no stress' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(false)
        allow(syl2).to receive(:main_stress?).and_return(false)
        allow(syl3).to receive(:main_stress?).and_return(false)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'with all syllables stressed' do
      before do
        allow(syl1).to receive(:main_stress?).and_return(true)
        allow(syl2).to receive(:main_stress?).and_return(true)
        allow(syl3).to receive(:main_stress?).and_return(true)
      end

      it 'assesses 3 violations' do
        expect(@content.eval_candidate(candidate)).to eq 3
      end
    end
  end
end
