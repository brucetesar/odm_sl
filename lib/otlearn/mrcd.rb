# frozen_string_literal: true

# Author: Bruce Tesar

require 'win_lose_pair'
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
  # A method will return a list of the winner-loser pairs constructed and
  # added. If the caller wants to accept the results of MRCD, it should
  # append the list of added winner-loser pairs to its own support.
  #
  # Once an Mrcd object has been constructed, it should be treated only
  # as a source of results; no further computation can be initiated on
  # the contents. Typically, a caller of Mrcd#new will retain a reference
  # to the original word list, and can obtain via Mrcd#added_pairs the
  # winner-loser pairs that were additionally constructed by MRCD.
  class Mrcd
    # The winner-loser pairs added by this execution of Mrcd.
    attr_reader :added_pairs

    # Returns a new Mrcd object containing the results of executing
    # MultiRecursive Constraint Demotion (MRCD) on +word_list+ starting
    # from +erc_list+. Both +word_list+ and +erc_list+ are duplicated
    # internally before use.
    # ==== Parameters
    # * word_list - list of words to be used as winners
    # * erc_list - the prior ranking information to use in learning
    # * selector - loser selection object.
    # :call-seq:
    #   Mrcd.new(word_list, erc_list, selector) -> mrcd
    #--
    # * single_mrcd_class - dependency injection parameter for testing.
    def initialize(word_list, erc_list, selector,
                   single_mrcd_class: OTLearn::MrcdSingle)
      # Make working copies of the word and ERC lists.
      @word_list = word_list.dup
      @erc_list = erc_list.dup
      @selector = selector # loser selector
      @single_mrcd_class = single_mrcd_class
      @added_pairs = []
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
    # further winner-loser pairs (ERCs).
    # Returns true.
    def run_mrcd
      loop do
        change_on_pass = word_list_pass
        # quit if the ERC list has become inconsistent
        break unless consistent?
        # repeat until a pass with no change
        break unless change_on_pass
      end
      true # arbitrary, to have a predictable return value
    end
    private :run_mrcd

    # Runs a single pass through the word list. Each word is treated as
    # a winner, and MRCD (via MrcdSingle) is run on that winner.
    # Any additionally constructed winner-loser pairs are added to both
    # the main ERC list and the list of only added pairs.
    # Returns a boolean indicating if at least one new winner-loser pair
    # was created and added.
    def word_list_pass
      change = false
      @word_list.each do |winner|
        # run MRCD on the winner
        mrcd_single = @single_mrcd_class.new(winner, @erc_list,
                                             @selector)
        # retrieve any added winner-loser pairs
        local_added_pairs = mrcd_single.added_pairs
        change = true unless local_added_pairs.empty?
        local_added_pairs.each do |p|
          @added_pairs << p
          @erc_list.add(p)
        end
        break unless consistent?
      end
      change
    end
    private :word_list_pass
  end
end
