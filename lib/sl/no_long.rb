# frozen_string_literal: true

# Author: Bruce Tesar

require 'constraint'

module SL
  # The markedness constraint NoLong assesses one violation for each output
  # syllable with a long vowel.
  class NoLong
    # The name of the constraint: NoLong.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a NoLong object.
    # :call-seq:
    #   new -> no_long
    def initialize
      @name = 'NoLong'
      @type = Constraint::MARK
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      cand.output.inject(0) do |sum, syl|
        syl.long? ? sum + 1 : sum
      end
    end
  end
end
