# frozen_string_literal: true

# Author: Bruce Tesar

require 'constraint'

module MultiStress
  # The markedness constraint Clash assesses one violation for each pair
  # of adjacent stressed syllables.
  class Clash
    # The name of the constraint: Clash.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a Clash object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'Clash'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      vcount = 0
      output = cand.output
      # Loop is never executed if (size-1) < 1
      (1..output.size - 1).each do |idx|
        if output[idx - 1].main_stress? && output[idx].main_stress?
          vcount += 1
        end
      end
      vcount
    end
  end
end
