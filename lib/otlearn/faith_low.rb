# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Represents the class of faithfulness constraints. Designed to be used
  # with RankingBiasSomeLow for biased constraint demotion.
  class FaithLow
    # Returns a new FaithLow object.
    # :call-seq:
    #   new -> faith_low
    def initialize; end

    # Returns true if _constraint_ is a faithfulness constraint,
    # false otherwise.
    def member?(constraint)
      constraint.faithfulness?
    end
  end
end
