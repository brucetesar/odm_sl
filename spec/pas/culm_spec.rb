# frozen_string_literal: true

# Author: Bruce Tesar / Morgan Moyer

require 'rspec'
require 'pas/culm'
require 'candidate'
require 'output'

module PAS
  RSpec.describe Culm do
    let(:candidate) { instance_double(Candidate, 'candidate') }
    let(:output) { instance_double(Output, 'output') }

    before do
      allow(candidate).to receive(:output).and_return(output)
      @content = described_class.new
    end

    it 'returns the name Culm' do
      expect(@content.name).to eq 'Culm'
    end

    it 'is a markedness constraint' do
      expect(@content.type).to eq Constraint::MARK
    end

    context 'when a candidate has a main stress' do
      before do
        allow(output).to receive(:main_stress?).and_return(true)
      end

      it 'assesses 0 violations' do
        expect(@content.eval_candidate(candidate)).to eq 0
      end
    end

    context 'when a candidate lacks a main stress' do
      before do
        allow(output).to receive(:main_stress?).and_return(false)
      end

      it 'assesses 1 violation' do
        expect(@content.eval_candidate(candidate)).to eq 1
      end
    end
  end
end
