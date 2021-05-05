# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Packages the key information about a language learning simulation.
  class LearningResult
    # A list of the learning steps taken during learning.
    attr_reader :step_list

    # The grammar produced by learning.
    attr_reader :grammar

    # Returns a learning result, containing _step_list_, a list of
    # the learning steps taken in the simulation, and _grammar_,
    # the grammar that learning produced.
    def initialize(step_list, grammar)
      @step_list = step_list
      @grammar = grammar
    end

    # Returns true if learning succeeded, false otherwise.
    def learning_successful?
      @step_list[-1].all_correct?
    end
  end
end
