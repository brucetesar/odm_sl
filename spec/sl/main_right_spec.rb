# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/main_right'
require 'constraint'
require 'sl/syllable'
require 'candidate'

module SL
  RSpec.describe MainRight do
    let(:candidate) { instance_double(Candidate, 'candidate') }
    let(:syl1) { instance_double(Syllable, 'syl1') }
    let(:syl2) { instance_double(Syllable, 'syl2') }
    let(:syl3) { instance_double(Syllable, 'syl3') }

    before do
      @content = described_class.new
    end

    it 'returns the name MR' do
      expect(@content.name).to eq 'MR'
    end

    it 'is a markedness constraint' do
      expect(@content.type).to eq Constraint::MARK
    end

    context 'with a 2-syl candidate' do
      before do
        output = [syl1, syl2]
        allow(candidate).to receive(:output).and_return(output)
      end

      context 'with initial main stress' do
        before do
          allow(syl1).to receive(:main_stress?).and_return(true)
          allow(syl2).to receive(:main_stress?).and_return(false)
        end

        it 'assesses 1 violation' do
          expect(@content.eval_candidate(candidate)).to eq 1
        end
      end

      context 'with final main stress' do
        before do
          allow(syl1).to receive(:main_stress?).and_return(false)
          allow(syl2).to receive(:main_stress?).and_return(true)
        end

        it 'assesses 0 violations' do
          expect(@content.eval_candidate(candidate)).to eq 0
        end
      end
    end

    context 'with a 3-syl candidate' do
      before do
        output = [syl1, syl2, syl3]
        allow(candidate).to receive(:output).and_return(output)
      end

      context 'with initial main stress' do
        before do
          allow(syl1).to receive(:main_stress?).and_return(true)
          allow(syl2).to receive(:main_stress?).and_return(false)
          allow(syl3).to receive(:main_stress?).and_return(false)
        end

        it 'assesses 2 violations' do
          expect(@content.eval_candidate(candidate)).to eq 2
        end
      end

      context 'with final main stress' do
        before do
          allow(syl1).to receive(:main_stress?).and_return(false)
          allow(syl2).to receive(:main_stress?).and_return(false)
          allow(syl3).to receive(:main_stress?).and_return(true)
        end

        it 'assesses 0 violations' do
          expect(@content.eval_candidate(candidate)).to eq 0
        end
      end

      context 'with penultimate main stress' do
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
    end
  end
end
