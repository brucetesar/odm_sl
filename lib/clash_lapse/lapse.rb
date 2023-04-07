# frozen_string_literal: true

# Author: Bruce Tesar

module ClashLapse
  # The markedness constraint Lapse assesses one violation for each pair
  # of adjacent unstressed syllables.
  class Lapse
    # The name of the constraint: Lapse.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a Lapse object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'Lapse'
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
        if output[idx - 1].unstressed? && output[idx].unstressed?
          vcount += 1
        end
      end
      vcount
    end
  end
end
