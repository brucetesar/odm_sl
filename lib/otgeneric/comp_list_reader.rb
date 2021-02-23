# frozen_string_literal: true

# Author: Bruce Tesar

require 'constraint'
require 'otgeneric/candidate_reader'

module OTGeneric
  # Contains methods for converting a competition list from an
  # array of strings representation to an array of competitions.
  class CompListReader
    # Returns a new CompListReader object.
    # :call-seq:
    #   CompListReader.new -> reader
    #--
    # cand_reader is a dependency injection, used for testing.
    #++
    def initialize(cand_reader: nil)
      @cand_reader = cand_reader
      @cand_reader ||= OTGeneric::CandidateReader.new
    end

    # Takes an array of column headers +headers+, and an array of arrays
    # +data+, and returns an equivalent Array of Arrays of Candidates.
    def arrays_to_comp_list(headers, data)
      @cand_reader.constraints = convert_headers_to_constraints(headers)
      all_candidates = convert_data_to_candidates(data)
      # sort candidates by input, create separate competitions
      all_cand_sorted = all_candidates.sort_by { |cand| cand.input.to_s }
      comps_enum = all_cand_sorted.chunk(&:input)
      comps_enum.map { |chunk| chunk[1] }
    end

    # Converts the header row of array representation of candidates.
    # Ignores the first two cells (the columns for input and output),
    # and for each subsequent value creates a Constraint object.
    # Returns an array of constraints.
    def convert_headers_to_constraints(headers)
      constraints = []
      con_headers = headers[2..-1] # all but first two cells
      con_headers.each_with_index do |head, i|
        con = Constraint.new(head, i, Constraint::MARK)
        constraints << con
      end
      constraints
    end
    protected :convert_headers_to_constraints

    # Converts each data row to a Candidate object.
    # Returns an array of the candidates.
    def convert_data_to_candidates(data)
      candidates = []
      data.each do |row|
        candidates << @cand_reader.convert_array_to_candidate(row)
      end
      candidates
    end
    protected :convert_data_to_candidates
  end
end
