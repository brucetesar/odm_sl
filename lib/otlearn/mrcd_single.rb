# frozen_string_literal: true

# Author: Bruce Tesar

require 'win_lose_pair'

module OTLearn
  # An MrcdSingle object contains the results of applying
  # MultiRecursive Constraint Demotion to a single winner, with respect
  # to a given ERC list and a given loser selection routine.
  # It does not modify the ERC list passed into the constructor.
  # Methods of the object will indicate if MRCD resulted in an
  # (in)consistent ERC list, and return a list of the winner-loser pairs
  # constructed and added. If the caller wants to accept the results of
  # MRCD, it should append the list of added winner-loser pairs to its
  # own grammar's support.
  class MrcdSingle
    # Returns the additional winner-loser pairs added to the ERC list
    # in order to make the winner optimal.
    attr_reader :added_pairs

    # Returns the winner that MrcdSingle attempted to make optimal.
    attr_reader :winner

    # Returns a new MrcdSingle object.
    # ==== Parameters
    # * winner - the candidate the learner is attempting to make optimal.
    # * erc_list - the ERC list being tested. This list is first
    #   duplicated internally, and so is not modified; the internal
    #   duplicate may have additional winner-loser pairs added to it.
    # * selector - the loser selector (given a winner and an ERC list).
    # :call-seq:
    #   new(winner, erc_list, selector) -> mrcdsingle
    #--
    # wl_pair_class is a dependency injection for testing.
    def initialize(winner, erc_list, selector, wl_pair_class: nil)
      @winner = winner
      @erc_list = erc_list.dup
      @added_pairs = []
      @selector = selector
      @wl_pair_class = wl_pair_class || WinLosePair
      run_mrcd_single
    end

    # Returns true if the internal ERC list is consistent, false otherwise.
    def consistent?
      @erc_list.consistent?
    end

    # Runs MRCD on the winner, using the given ERC list and loser selector.
    # Called automatically by the constructor.
    def run_mrcd_single
      loser = @selector.select_loser(@winner, @erc_list)
      until loser.nil?
        # Create a new WL pair.
        new_pair = @wl_pair_class.new(@winner, loser)
        new_pair.label = @winner.morphword.to_s
        # Add the new pair to the added pairs list and the ERC list.
        @added_pairs << new_pair
        @erc_list.add(new_pair)
        # break out of the loop if the ERC list is inconsistent
        break unless @erc_list.consistent?

        loser = @selector.select_loser(@winner, @erc_list)
      end
      true
    end
    protected :run_mrcd_single
  end
end
