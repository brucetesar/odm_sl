# frozen_string_literal: true

# Author: Bruce Tesar

module SL
  # The markedness constraint WSP assesses one violation for each output
  # syllable with a long vowel that is unstressed.
  class Wsp
    # The name of the constraint: WSP.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a Wsp object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'WSP'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      cand.output.inject(0) do |sum, syl|
        syl.long? && syl.unstressed? ? sum + 1 : sum
      end
    end
  end
end
