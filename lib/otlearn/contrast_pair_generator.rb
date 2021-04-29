# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/grammar_test'
require 'word_search'

module OTLearn
  # Generates a sequence of contrast pairs, derived from the list of
  # outputs and the grammar provided to the constructor.
  class ContrastPairGenerator
    def initialize(outputs, grammar, grammar_tester: GrammarTest.new,
                   word_searcher: WordSearch.new)
      @outputs = outputs
      @grammar = grammar
      @grammar_tester = grammar_tester
      @word_searcher = word_searcher
      @test_result = nil
      @failed_winners = nil
      pre_process_words
    end

    def pre_process_words
      # run grammar test, get failed and successful outputs
      @test_result = @grammar_tester.run(@outputs, @grammar)
      failed_outputs = @test_result.failed_outputs
      success_outputs = @test_result.success_outputs
      # convert outputs to full winner candidates, synchronized with
      # the grammar's lexicon.
      @failed_winners =
        failed_outputs.map { |o| @grammar.parse_output(o) }
      @success_winners =
        success_outputs.map { |o| @grammar.parse_output(o) }
    end
    private :pre_process_words

    def each
      # iterate over failed winners
      #   remove failed winner from working list of winners
      #   iterate over morphemes of the failed winner
      #     find unset features of failed winner outside of target morpheme
      #     find working list winners that differ only in the target morpheme
      #     iterate over candidate winners
      #       if failed_winner and candidate_winner alternate on an unset feature
      #         yield the pair as a contrast pair
      yield [@failed_winners[0], @success_winners[0]]
    end
  end
end
