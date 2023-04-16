# frozen_string_literal: true

# Author: Bruce Tesar

module MultiStress
  # The markedness constraint StressRight assesses, for each stressed
  # syllable, one violation for each syllable that follows it.
  # It is technically an alignment constraint, directly aligning stressed
  # syllables with the right edge of the word, with syllables (stressed or
  # not) used as the intervenors.
  class StressRight
    # The name of the constraint: SR.
    attr_reader :name

    # The type of the constraint: MARK.
    attr_reader :type

    # Returns a StressRight object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'SR'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      output = cand.output
      viol_count = 0
      last_idx = output.length - 1 # the index of the rightmost syllable.
      output.each_with_index do |syl, idx|
        # A violation for each syllable between current and right edge,
        # if the current syllable is stressed.
        viol_count += (last_idx - idx) if syl.main_stress?
      end
      viol_count
    end
  end
end
