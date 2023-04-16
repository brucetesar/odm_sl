# frozen_string_literal: true

# Author: Bruce Tesar

require 'constraint'

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
    #   new -> constraint_content
    def initialize
      @name = 'MR'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      output = cand.output
      viol_count = 0
      rightmost_idx = output.length - 1
      idx = rightmost_idx
      # Loop over the syllables of the output, right-to-left.
      # A negative index means the left edge of the word has been
      # reached, so there is no main stress in the output.
      until idx.negative?
        if output[idx].main_stress?
          # violations = number of syllables to the right of main stress.
          viol_count = rightmost_idx - idx
          # break out of the loop; syls to left of main stress are irrelevant.
          break
        end
        # Decrement to the next syllable to the left.
        idx -= 1
      end
      viol_count
    end
  end
end
