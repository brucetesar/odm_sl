# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/mrcd'
require 'compare_consistency'
require 'loser_selector_from_gen'

module OTLearn
  # Learns ERCs (ranking information) based on a word list and
  # an existing grammar. The grammar object passed in to #run
  # is directly updated with any additional winner-loser pairs
  # produced by learning.
  class ErcLearning
    # Selects informative losers for new ERCs
    attr_accessor :loser_selector

    # Returns a new ErcLearning object.
    # :call-seq:
    #   ErcLearning.new -> learner
    #--
    # mrcd_class is a dependency injection used for testing.
    def initialize(mrcd_class: nil)
      @loser_selector = nil
      @mrcd_class = mrcd_class || Mrcd
    end

    # Runs ERC learning, returning an Mrcd object based on _word_list_
    # and _grammar_.
    # :call-seq:
    #   run(word_list, grammar) -> mrcd
    def run(word_list, grammar)
      default_loser_selector(grammar.system) if @loser_selector.nil?
      mrcd_result = @mrcd_class.new(word_list, grammar.erc_list,
                                    @loser_selector)
      mrcd_result.added_pairs.each { |pair| grammar.add_erc(pair) }
      mrcd_result
    end

    # Constructs the default loser selector.
    def default_loser_selector(system)
      @loser_selector =
        LoserSelectorFromGen.new(system, CompareConsistency.new)
    end
    private :default_loser_selector
  end
end
