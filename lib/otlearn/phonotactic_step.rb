# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # The results of a phonotactic learning step.
  class PhonotacticStep
    # The learning step type, OTLearn::PHONOTACTIC.
    attr_reader :step_type

    # The result of grammar testing at the end of the learning step.
    attr_reader :test_result

    # Returns a new step object for phonotactic learning.
    # === Parameters
    # * _test_result_ - the test result run at the end of the step.
    # * _changed_ - a boolean indicating of the step changed the grammar.
    # :call-seq:
    #   new(test_result, changed) -> step
    def initialize(test_result, changed)
      @test_result = test_result
      @changed = changed
      @step_type = PHONOTACTIC
    end

    # Returns true if the grammar was changed by the learning step;
    # returns false otherwise.
    def changed?
      @changed
    end

    # Returns true if all data (words) pass grammar testing (indicating
    # that learning is complete and successful).
    def all_correct?
      @test_result.all_correct?
    end
  end
end
