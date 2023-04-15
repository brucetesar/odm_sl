# frozen_string_literal: true

# Author: Bruce Tesar

module MultiStress
  # The markedness constraint StressLeft assesses, for each stressed
  # syllable, one violation for each syllable that precedes it.
  # It is technically an alignment constraint, directly aligning stressed
  # syllables with the left edge of the word, with syllables (stressed or
  # not) used as the intervenors.
  class StressLeft
    # The name of the constraint: SL.
    attr_reader :name

    # The type of the constraint: MARK.
    attr_reader :type

    # Returns a StressLeft object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'SL'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      viol_count = 0
      cand.output.each_with_index do |syl, idx|
        viol_count += idx if syl.main_stress?
      end
      viol_count
    end
  end
end
