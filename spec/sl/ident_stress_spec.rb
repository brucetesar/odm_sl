# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'sl/ident_stress'
require 'constraint'
require 'sl/syllable'

module SL
  RSpec.describe IdentStress do
    # Cannot make word an instance double, because Word delegates many
    # methods to an internal Candidate object, and #instance_double
    # cannot follow the delegation (it's not statically defined).
    let(:word) { double('word') }
    let(:syli1) { instance_double(Syllable, 'syli1') }
    let(:syli2) { instance_double(Syllable, 'syli2') }
    let(:syli3) { instance_double(Syllable, 'syli3') }
    let(:sylo1) { instance_double(Syllable, 'sylo1') }
    let(:sylo2) { instance_double(Syllable, 'sylo2') }
    let(:sylo3) { instance_double(Syllable, 'sylo3') }

    before do
      allow(syli1).to receive(:stress_unset?).and_return(false)
      allow(syli2).to receive(:stress_unset?).and_return(false)
      allow(syli3).to receive(:stress_unset?).and_return(false)
      allow(word).to receive(:io_out_corr).with(syli1).and_return(sylo1)
      allow(word).to receive(:io_out_corr).with(syli2).and_return(sylo2)
      allow(word).to receive(:io_out_corr).with(syli3).and_return(sylo3)
      @content = described_class.new
    end

    it 'returns the name IDStress' do
      expect(@content.name).to eq 'IDStress'
    end

    it 'is a faithfulness constraint' do
      expect(@content.type).to eq Constraint::FAITH
    end

    context 'when a word has faithful main stress' do
      before do
        allow(syli1).to receive(:main_stress?).and_return(true)
        allow(syli2).to receive(:main_stress?).and_return(false)
        allow(sylo1).to receive(:main_stress?).and_return(true)
        allow(sylo2).to receive(:main_stress?).and_return(false)
        input = [syli1, syli2]
        allow(word).to receive(:input).and_return(input)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(word)).to eq 0
      end
    end

    context 'when a word has mismatched main stresses' do
      before do
        allow(syli1).to receive(:main_stress?).and_return(true)
        allow(syli2).to receive(:main_stress?).and_return(false)
        allow(sylo1).to receive(:main_stress?).and_return(false)
        allow(sylo2).to receive(:main_stress?).and_return(true)
        input = [syli1, syli2]
        allow(word).to receive(:input).and_return(input)
      end

      it 'assesses 2 violations' do
        expect(@content.eval_candidate(word)).to eq 2
      end
    end

    context 'when a word has two input main stresses and one output' do
      before do
        allow(syli1).to receive(:main_stress?).and_return(true)
        allow(syli2).to receive(:main_stress?).and_return(false)
        allow(syli3).to receive(:main_stress?).and_return(true)
        allow(sylo1).to receive(:main_stress?).and_return(true)
        allow(sylo2).to receive(:main_stress?).and_return(false)
        allow(sylo3).to receive(:main_stress?).and_return(false)
        input = [syli1, syli2, syli3]
        allow(word).to receive(:input).and_return(input)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(word)).to eq 1
      end
    end
  end
end
