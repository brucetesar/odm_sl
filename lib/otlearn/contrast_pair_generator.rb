# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/grammar_test'
require 'otlearn/contrast_word_finder'

module OTLearn
  # Yields a sequence of contrast pairs via method #each().
  # The contrast pairs are derived from a list of outputs and a grammar,
  # each of which must be provided via attribute assignment before
  # #each() is called.
  #
  # These objects can be converted to enumerators, and used
  # in that fashion:
  #   cp_gen = ContrastPairGenerator.new
  #   cp_gen.outputs = outputs
  #   cp_gen.grammar = grammar
  #   cp_enum = cp_gen.to_enum
  #   loop { contrast_pair = cp_enum.next; <...> }
  class ContrastPairGenerator
    # The grammar testing object. Default: GrammarTest.new.
    attr_accessor :grammar_tester

    # The outputs of the language.
    attr_accessor :outputs

    # The grammar.
    attr_accessor :grammar

    # Returns a new contrast pair generator.
    # :call-seq:
    #   new() -> generator
    #--
    # Named parameter contrast_finder is a dependency injection used
    # for testing.
    def initialize(contrast_finder: nil)
      @contrast_finder = contrast_finder
    end

    # Successively yields valid contrast pairs, where the two words
    # meet the conditions of a contrast pair as defined in the
    # contrast finder (normally OTLearn::ContrastWordFinder).
    # Returns nil.
    #
    # Raises a RuntimeError if either the outputs or the grammar have
    # not been provided via attribute setting.
    def each # :yields: contrast_pair
      check_defaults_pre_processing
      failed_queue = @failed_winners.dup
      until failed_queue.empty?
        fwinner = failed_queue.shift
        contrast_candidates = failed_queue + @success_winners
        cwords =
          @contrast_finder.contrast_words(fwinner, contrast_candidates,
                                          grammar)
        cwords.each { |word| yield [fwinner, word] }
      end
      nil
    end

    # Assigns default values for the grammar tester and the contrast
    # finder if they have not already been assigned.
    # Runs word pre-processing if it has not already been run.
    # Raises a RuntimeError if either the outputs or the grammar have
    # not been provided via attribute setting.
    def check_defaults_pre_processing
      msg1 = 'ContrastPairGenerator: no outputs provided.'
      msg2 = 'ContrastPairGenerator: no grammar provided.'
      raise msg1 if @outputs.nil?
      raise msg2 if @grammar.nil?

      @grammar_tester ||= GrammarTest.new
      @contrast_finder ||= ContrastWordFinder.new
      pre_process_words if @failed_winners.nil? || @success_winners.nil?
    end
    private :check_defaults_pre_processing

    # Runs a grammar test to find currently failing and succeeding winners.
    # Returns true.
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
      true
    end
    private :pre_process_words
  end
end
