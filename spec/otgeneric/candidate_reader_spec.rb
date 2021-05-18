# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require 'otgeneric/candidate_reader'

RSpec.describe OTGeneric::CandidateReader do
  context 'with an array with three constraints' do
    let(:con_list) { ['Con1', 'Con2', 'Con3'] }
    let(:data_row) { ['in1', 'out11', '0', '3', '2'] }

    before do
      @cand_reader = described_class.new
      @cand_reader.constraints = con_list
      @candidate = @cand_reader.convert_array_to_candidate(data_row)
    end

    it 'returns a candidate with three constraints' do
      expect(@candidate.constraint_list.size).to eq 3
    end

    it 'returns a list of the constraints' do
      expect(@cand_reader.constraints).to equal(con_list)
    end

    it 'returns a candidate with 0 violations of Con1' do
      expect(@candidate.get_viols(con_list[0])).to eq 0
    end

    it 'returns a candidate with 3 violations of Con2' do
      expect(@candidate.get_viols(con_list[1])).to eq 3
    end

    it 'returns a candidate with 2 violations of Con3' do
      expect(@candidate.get_viols(con_list[2])).to eq 2
    end

    context 'with a data row with two violation columns' do
      let(:row_too_short) { ['in2', 'out21', '2', '1'] }

      it 'raises an exception' do
        expect { @cand_reader.convert_array_to_candidate(row_too_short) }.to\
          raise_error(RuntimeError,
                      'Candidate /in2/[out21] has 2 violation counts' \
                        ', headers have 3 constraints.')
      end
    end

    context 'with a data row with four violation columns' do
      let(:row_too_long) { ['in2', 'out21', '2', '1', '0', '3'] }

      it 'raises an exception' do
        expect { @cand_reader.convert_array_to_candidate(row_too_long) }.to\
          raise_error(RuntimeError,
                      'Candidate /in2/[out21] has 4 violation counts' \
                        ', headers have 3 constraints.')
      end
    end

    context 'with a non-numeric violation count' do
      let(:row_nonnum) { ['in2', 'out21', '2', 'J', '0'] }

      it 'raises an exception' do
        expect { @cand_reader.convert_array_to_candidate(row_nonnum) }.to\
          raise_error(RuntimeError,
                      'Candidate /in2/[out21] has' \
                        ' non-numeric violation value J' \
                        ' for constraint Con2.')
      end
    end
  end
end
