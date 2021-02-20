# frozen_string_literal: true

# Author: Bruce Tesar

require 'candidate'

module OTGeneric

  # Contains methods for converting a candidate from an
  # array of strings representation to a Candidate object.
  class CandidateReader

    # The list of constraints.
    attr_accessor :constraints

    # Returns a new CandidateReader object.
    def initialize
      # Initialize the list of constraints to an empty array.
      @constraints = []
    end

    # Given a list of string data _row_ representing a candidate,
    # returns a corresponding Candidate object.
    # Raises a RuntimeError if:
    # * the number of violation columns doesn't match the number of
    #   constraint headers.
    # * a violation column entry does not represent an integer.
    def convert_array_to_candidate(row)
      # Check the number of violation columns.
      check_violation_col_count(row)
      # Create a new Candidate object.
      cand = Candidate.new(row[0], row[1], @constraints)
      # Set the constraint violation counts for the candidate.
      @constraints.each_with_index do |con, idx|
        viol_value = row[idx+2]
        check_violation_value(viol_value, con, row)
        viol_count = viol_value.to_i
        cand.set_viols(con, viol_count)
      end
      cand
    end

    # Verify the number of violation cols matches the number of constraints.
    # Raise a RuntimeError if they don't.
    def check_violation_col_count(row)
      row_viols = row.size - 2
      con_count = @constraints.size
      if row_viols != con_count
        msg = "Candidate /#{row[0]}/[#{row[1]}]" +
          " has #{row_viols} violation counts" +
          ", headers have #{con_count} constraints."
        raise(msg)
      end
      true
    end
    protected :check_violation_col_count

    # Verify that the violation value is valid (a positive integer).
    # Raise a RuntimeError if it is not.
    def check_violation_value(viol_value, con, row)
      unless valid_violation_value?(viol_value)
        msg1 = "Candidate /#{row[0]}/[#{row[1]}]"
        msg2 = "has non-numeric violation value #{viol_value}"
        msg3 = "for constraint #{con.to_s}."
        raise "#{msg1} #{msg2} #{msg3}"
      end
      true
    end
    protected :check_violation_value

    # Returns true if the string _viol_value_ contains only digits.
    # Returns false otherwise.
    def valid_violation_value?(viol_value)
      return false unless /^[0-9]+$/ =~ viol_value
      true
    end
    protected :valid_violation_value?
  end
end