# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otgeneric/winners_reader'

RSpec.describe OTGeneric::WinnersReader do
  let(:cand11) { double('candidate11') }
  let(:cand12) { double('candidate12') }
  let(:cand21) { double('candidate21') }
  let(:cand22) { double('candidate22') }

  before do
    allow(cand11).to receive(:input).and_return('in1')
    allow(cand12).to receive(:input).and_return('in1')
    allow(cand21).to receive(:input).and_return('in2')
    allow(cand22).to receive(:input).and_return('in2')
    allow(cand11).to receive(:output).and_return('out11')
    allow(cand12).to receive(:output).and_return('out12')
    allow(cand21).to receive(:output).and_return('out21')
    allow(cand22).to receive(:output).and_return('out22')
  end

  context 'with an array with one winner' do
    before do
      data = [%w[in1 out11]]
      comp_list = [[cand11, cand12], [cand21, cand22]]
      @win_reader = described_class.new
      @win_reader.competitions = comp_list
      @winner_list = @win_reader.convert_array_to_winners(data)
    end

    it 'returns an array with one winning candidate' do
      expect(@winner_list.size).to eq 1
    end

    it 'returns an array including a candidate with input in1' do
      expect(@winner_list[0].input).to eq 'in1'
    end

    it 'returns an array including a candidate with output out11' do
      expect(@winner_list[0].output).to eq 'out11'
    end
  end

  context 'with an array with two winners' do
    before do
      data = [%w[in1 out12], %w[in2 out21]]
      comp_list = [[cand11, cand12], [cand21, cand22]]
      @win_reader = described_class.new
      @win_reader.competitions = comp_list
      @winner_list = @win_reader.convert_array_to_winners(data)
    end

    it 'returns an array with two winning candidates' do
      expect(@winner_list.size).to eq 2
    end

    it 'returns an array including a candidate with input in1' do
      expect(@winner_list[0].input).to eq 'in1'
    end

    it 'returns an array including a candidate with output out12' do
      expect(@winner_list[0].output).to eq 'out12'
    end

    it 'returns an array including a candidate with input in2' do
      expect(@winner_list[1].input).to eq 'in2'
    end

    it 'returns an array including a candidate with output out21' do
      expect(@winner_list[1].output).to eq 'out21'
    end
  end

  context 'with a winner with input with no corresponding competition' do
    before do
      @data = [%w[in1 out12], %w[in3 out31]]
      comp_list = [[cand11, cand12], [cand21, cand22]]
      @win_reader = described_class.new
      @win_reader.competitions = comp_list
    end

    it 'raises a RuntimeError' do
      msg = 'Winner has input in3, but there is no such competition.'
      expect { @win_reader.convert_array_to_winners(@data) }.to\
        raise_error(RuntimeError, msg)
    end
  end

  context 'with a winner with no output in its competition' do
    before do
      @data = [%w[in1 out12], %w[in2 out31]]
      comp_list = [[cand11, cand12], [cand21, cand22]]
      @win_reader = described_class.new
      @win_reader.competitions = comp_list
    end

    it 'raises a RuntimeError' do
      msg = 'Winner has input in2 output out31, but there is no such candidate.'
      expect { @win_reader.convert_array_to_winners(@data) }.to\
        raise_error(RuntimeError, msg)
    end
  end
end
