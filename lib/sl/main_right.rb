# frozen_string_literal: true

# Author: Bruce Tesar

module SL
  # The markedness constraint MainRight assesses one violation for each
  # syllable that follows a main stress syllable. If the word has no
  # main stress, 0 violations are assessed.
  class MainRight
    # The name of the constraint: MR.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a MainRight object.
    # :call-seq:
    #   new -> main_right
    def initialize
      @name = 'MR'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      viol_count = 0
      stress_found = false
      cand.output.each do |syl|
        viol_count += 1 if stress_found
        stress_found = true if syl.main_stress?
      end
      viol_count
    end
  end
end
