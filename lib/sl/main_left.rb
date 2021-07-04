# frozen_string_literal: true

# Author: Bruce Tesar

module SL
  # The markedness constraint MainLeft assesses one violation for each
  # syllable that precedes a main stress syllable. If the word has no
  # main stress, 0 violations are assessed.
  class MainLeft
    # The name of the constraint: ML.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a MainLeft object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'ML'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      # 0 violations if there is no main stress
      return 0 unless cand.output.any?(&:main_stress?)

      viol_count = 0
      cand.output.each do |syl|
        break if syl.main_stress?

        viol_count += 1
      end
      viol_count
    end
  end
end
