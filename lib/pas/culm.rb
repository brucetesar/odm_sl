# frozen_string_literal: true

# Author: Bruce Tesar / Morgan Moyer

require 'constraint'

module PAS
  # The markedness constraint Culm assesses one violation if the candidate
  # lacks a main stress; 0 violations otherwise.
  class Culm
    # The name of the constraint: Culm.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a Culm object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'Culm'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      cand.output.main_stress? ? 0 : 1
    end
  end
end
