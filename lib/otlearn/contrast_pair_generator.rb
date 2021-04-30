# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/grammar_test'
require 'otlearn/contrast_word_finder'

module OTLearn
  # Yields a sequence of contrast pairs, derived from the list of
  # outputs and the grammar provided to the constructor.
  #
  # These objects will normally be converted to enumerators, and used
  # in that fashion:
  #   cp_enum = ContrastPairGenerator.new(outputs, grammar).to_enum
  #   loop { contrast_pair = cp_enum.next; <...> }
  class ContrastPairGenerator
    # Returns a new contrast pair generator.
    # === Parameters
    # * outputs - the outputs of the language.
    # * grammar - the grammar.
    # :call-seq:
    #   new(outputs, grammar) -> generator
    #--
    # Named parameters grammar_tester and contrast_finder are dependency
    # injections used for testing.
    def initialize(outputs, grammar, grammar_tester: GrammarTest.new,
                   contrast_finder: nil)
      @outputs = outputs
      @grammar = grammar
      @grammar_tester = grammar_tester
      @contrast_finder = contrast_finder
      @contrast_finder ||= ContrastWordFinder.new(@grammar)
      pre_process_words
    end

    # Runs a grammar test to find currently failing and succeeding winners.
    # Returns true.
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
      true
    end
    private :pre_process_words

    # Successively yields valid contrast pairs, where the two words
    # meet the conditions of a contrast pair as defined in the
    # contrast finder (normally OTLearn::ContrastWordFinder).
    # Returns nil.
    def each # :yields: contrast_pair
      failed_queue = @failed_winners.dup
      until failed_queue.empty?
        fwinner = failed_queue.shift
        contrast_candidates = failed_queue + @success_winners
        cwords = @contrast_finder.contrast_words(fwinner, contrast_candidates)
        cwords.each { |word| yield [fwinner, word] }
      end
      nil
    end
  end
end
