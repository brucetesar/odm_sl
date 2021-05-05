# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/mrcd_single'

module OTLearn
  # An Mrcd object contains the results of applying MultiRecursive
  # Constraint Demotion to a given list of words with respect to a given
  # ERC list. The word list and ERC list are provided as arguments to the
  # constructor, Mrcd#new. The MRCD algorithm is immediately executed
  # as part of construction of the Mrcd object.
  #
  # Both the word list and the ERC list passed to the constructor
  # are duplicated internally prior to use, so that the original objects
  # passed in are not affected by the operations of Mrcd.
  # Attributes make available a list of the prior ERCs originally passed
  # in, a list of the added winner-loser pairs, and a combined ERC list
  # including both prior and added ranking information.
  #
  # Once an Mrcd object has been constructed, it should be treated only
  # as a source of results; no further computation can be initiated on
  # the contents, and the retrievable lists of ranking information are
  # frozen.
  class Mrcd
    # The winner-loser pairs added by this execution of MRCD.
    attr_reader :added_pairs

    # The ranking information (ERCs) provided at construction.
    attr_reader :prior_ercs

    # All of the ranking information, prior and added.
    attr_reader :erc_list

    # Returns a new Mrcd object containing the results of executing
    # MultiRecursive Constraint Demotion (MRCD) on _word_list_ starting
    # from _erc_list_. Both _word_list_ and _erc_list_ are duplicated
    # internally before use.
    # ==== Parameters
    # * word_list - list of words to be used as winners
    # * erc_list - the prior ranking information to use in learning
    # * selector - loser selection object.
    # :call-seq:
    #   Mrcd.new(word_list, erc_list, selector) -> mrcd
    #--
    # * single_mrcd_class - dependency injection parameter for testing.
    def initialize(word_list, erc_list, selector, single_mrcd_class: nil)
      # Make working copies of the word and ERC lists.
      @word_list = word_list.dup
      @prior_ercs = erc_list.dup.freeze
      @erc_list = erc_list.dup
      @added_pairs = []
      @selector = selector # loser selector
      @single_mrcd_class = single_mrcd_class || MrcdSingle
      run_mrcd
    end

    # Returns true if the internal ERC list is consistent,
    # false otherwise.
    def consistent?
      @erc_list.consistent?
    end

    # Returns true if any ERCs were added by MRCD.
    # Returns false otherwise.
    def any_change?
      !@added_pairs.empty?
    end

    # Runs MRCD on the given word list, making repeated passes through
    # the word list until pass is completed without generating any
    # further winner-loser pairs (ERCs). The list of added winner-loser
    # pairs and the full ERC list are both frozen after MRCD is complete.
    # Returns true.
    def run_mrcd
      loop do
        change_on_pass = word_list_pass
        # quit if the ERC list has become inconsistent
        break unless consistent?
        # repeat until a pass with no change
        break unless change_on_pass
      end
      @added_pairs.freeze
      @erc_list.freeze
      true # arbitrary, to have a predictable return value
    end
    private :run_mrcd

    # Runs a single pass through the word list. Each word is treated as
    # a winner and processed (MRCD is run to search for additional
    # winner-loser pairs). The pass is terminated if the processing of
    # a winner makes the overall list of ERCs inconsistent.
    # Returns a boolean indicating if at least one new winner-loser pair
    # was created and added during the pass.
    def word_list_pass
      change_on_pass = false
      @word_list.each do |winner|
        # run MRCD on the winner, find if any change occurred.
        change = process_winner(winner)
        change_on_pass = true if change
        break unless consistent?
      end
      change_on_pass
    end
    private :word_list_pass

    # Runs MRCD on _winner_, adding any newly constructed winner-loser
    # pairs to the ERC list (and the added pairs list). Returns true if
    # at least one new winner-loser pair was generated, false otherwise.
    def process_winner(winner)
      mrcd_single =
        @single_mrcd_class.new(winner, @erc_list, @selector)
      # retrieve any added winner-loser pairs
      local_added_pairs = mrcd_single.added_pairs
      local_added_pairs.each do |p|
        @added_pairs << p
        @erc_list.add(p)
      end
      # Return true if any pairs were added, false otherwise.
      !local_added_pairs.empty?
    end
    private :process_winner
  end
end
