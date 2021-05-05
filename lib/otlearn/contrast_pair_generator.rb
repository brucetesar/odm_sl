# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/grammar_test'
require 'otlearn/contrast_word_finder'

module OTLearn
  # Yields a sequence of contrast pairs via method #each().
  # The contrast pairs are derived from a list of outputs and a grammar,
  # which are provided via the constructor.
  #
  # These objects can be converted to enumerators, and used
  # in that fashion:
  #   cp_gen = ContrastPairGenerator.new(outputs, grammar)
  #   cp_enum = cp_gen.to_enum
  #   loop { contrast_pair = cp_enum.next; <...> }
  class ContrastPairGenerator
    # The grammar testing object. Default: GrammarTest.new.
    attr_accessor :grammar_tester

    # Returns a new contrast pair generator.
    # === Parameters
    # * outputs - the outputs of the language.
    # * grammar - the learner's current grammar.
    # :call-seq:
    #   new(outputs, grammar) -> generator
    #--
    # Named parameter contrast_finder is a dependency injection used
    # for testing.
    def initialize(outputs, grammar, contrast_finder: nil)
      @outputs = outputs
      @grammar = grammar
      @contrast_finder = contrast_finder
    end

    # Successively yields valid contrast pairs, where the two words
    # meet the conditions of a contrast pair as defined in the
    # contrast finder (normally OTLearn::ContrastWordFinder).
    # Returns nil.
    def each # :yields: contrast_pair
      check_defaults_pre_processing
      failed_queue = @failed_winners.dup
      until failed_queue.empty?
        fwinner = failed_queue.shift
        contrast_candidates = failed_queue + @success_winners
        cwords = @contrast_finder\
                 .contrast_words(fwinner, contrast_candidates, @grammar)
        cwords.each { |word| yield [fwinner, word] }
      end
      nil
    end

    # Assigns default values for the grammar tester and the contrast
    # finder if they have not already been assigned.
    # Runs word pre-processing. Returns nil.
    def check_defaults_pre_processing
      @grammar_tester ||= GrammarTest.new
      @contrast_finder ||= ContrastWordFinder.new
      pre_process_words
      nil
    end
    private :check_defaults_pre_processing

    # Runs a grammar test to find currently failing and succeeding
    # winners. Returns nil.
    def pre_process_words
      # run grammar test, get failed and successful outputs
      test_result = @grammar_tester.run(@outputs, @grammar)
      failed_outputs = test_result.failed_outputs
      success_outputs = test_result.success_outputs
      # convert outputs to full winner candidates, synchronized with
      # the grammar's lexicon.
      @failed_winners =
        failed_outputs.map { |o| @grammar.parse_output(o) }
      @success_winners =
        success_outputs.map { |o| @grammar.parse_output(o) }
      nil
    end
    private :pre_process_words
  end
end
