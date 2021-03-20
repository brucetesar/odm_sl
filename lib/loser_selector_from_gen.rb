# frozen_string_literal: true

# Author: Bruce Tesar

# This class is an "adapter" class, in that it adapts a
# LoserSelectorFromCompetition object, which requires that a competition
# be provided, to situations in which the competition is implicitly
# assumed to be the product of GEN being applied to the input of the
# winner.
#
# An object of this class is constructed with provided system and
# selector objects, and when it receives the method call
# #select_loser(winner, ranking_info),
# it calls the system's GEN with the input of the winner, and then feeds
# that competition (along with the winner and rank_info) to the selector,
# returning the selector's result.
class LoserSelectorFromGen
  # Constructs a new LoserSelectorFromGen object, given a _system_ and
  # a loser _selector_.
  #
  # === Parameters
  # * _system_ - provides access to GEN for the linguistic system.
  # * _selector_ - a loser_selector object that expects to be provided
  #   with a list of candidates from which to select a loser.
  # :call-seq:
  #   LoserSelectorFromGen.new(system, selector) -> selector_from_gen
  def initialize(system, selector)
    @system = system
    @selector = selector
  end

  # Returns the informative loser from among the competition generated
  # by GEN for the winner's input. Returns nil if no informative loser
  # is found.
  #
  # :call-seq:
  #   select_loser(winner, ranking_info) -> candidate or nil
  def select_loser(winner, ranking_info)
    # Obtain the competition from GEN.
    competition = @system.gen(winner.input)
    # Return whatever @selector.select_loser returns.
    @selector.select_loser(winner, competition, ranking_info)
  end
end
