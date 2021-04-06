# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/mrcd'
require 'comparer_factory'
require 'loser_selector_from_gen'

module OTLearn
  # Checks a set of words for collective consistency with a given grammar.
  # MRCD is used to determine consistency; if MRCD can find a ranking that
  # is consistent with the prior ERCs of the grammar and makes each of
  # the words optimal, then the words are collectively consistent with
  # the grammar.
  #
  # Once a ConsistencyChecker is created, it has two execution entry
  # points:
  # * _consistent?_ evaluates a list of fully-determined words, assumed to
  #   have values assigned to all of their input features.
  # * _mismatch_consistent?_ evaluates a list of outputs, by creating,
  #   for each output, the word with the maximum mismatched input,
  #   meaning that each unset feature for a word is assigned an input
  #   value opposite of its output realization for that word.
  #
  # Because it is only checking consistency, finding a single hierarchy in
  # which all of the words are simultaneously optimal is sufficient. Thus,
  # ordinarily a loser selector that uses the Pool comparison method and
  # the all-high ranking bias is sufficient (and more efficient). That is
  # the default; the attribute _loser_selector_ need only be assigned
  # externally if you wish to do something different.
  class ConsistencyChecker
    # Selects informative losers; used by Mrcd. Default: Pool with the
    # all-high ranking bias.
    attr_accessor :loser_selector

    # Returns a new ConsistencyChecker object.
    # :call-seq:
    #   ConsistencyChecker.new -> checker
    #--
    # mrcd_class is a dependency injection used for testing.
    def initialize(mrcd_class: Mrcd)
      @loser_selector = nil
      @mrcd_class = mrcd_class
    end

    # Computes the mismatch input candidate for each output, and tests
    # the set candidates for consistency with the grammar. The mismatching
    # is done separately for each word, i.e., the same unset feature of
    # a morpheme might be assigned different values in the inputs of
    # different words, depending on the outputs of those words.
    # Returns true if the candidates are collectively consistent,
    # false otherwise.
    # :call-seq:
    #   mismatch_consistent?(output_list, grammar) -> boolean
    def mismatch_consistent?(output_list, grammar)
      mismatch_list = output_list.map do |output|
        word = grammar.parse_output(output)
        word.mismatch_input_to_output!
      end
      consistent?(mismatch_list, grammar)
    end

    # Tests the list of words for consistency with the grammar.
    # The words are presumed to be full candidates, with fully
    # determined inputs (all input features have been assigned values).
    # Returns true if the words are collectively consistent, false
    # otherwise.
    # :call-seq:
    #   consistent?(word_list, grammar) -> boolean
    def consistent?(word_list, grammar)
      default_loser_selector(grammar.system) if @loser_selector.nil?
      # Use Mrcd to determine collective consistency.
      mrcd_result = @mrcd_class.new(word_list, grammar.erc_list,
                                    @loser_selector)
      mrcd_result.consistent?
    end

    # Constructs the default loser selector, which uses the Pool comparsion
    # method and the all-high ranking bias.
    def default_loser_selector(system)
      factory = ComparerFactory.new
      factory.pool.all_high
      comparer = factory.build
      @loser_selector = LoserSelectorFromGen.new(system, comparer)
    end
    private :default_loser_selector
  end
end
