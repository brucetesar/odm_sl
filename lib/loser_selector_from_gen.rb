# frozen_string_literal: true

# Author: Bruce Tesar

require 'loser_selector_from_competition'

# An object of this class selects an informative loser, if one exists,
# for a given winner relative to given ranking information.
# It is based on the linguistic system's GEN, meaning that it searches
# the entire space of candidates, as provided by GEN, for the input
# of the winner.
#
# A LoserSelectorFromGen is constructed with provided system and
# comparer objects, and uses the comparer to build a loser selector
# that operates over an entire competition (list of candidates).
# When it receives the method call #select_loser(winner, ranking_info),
# it calls the system's GEN with the input of the winner, and then feeds
# that competition (along with the winner and rank_info) to the
# constructed selector, returning the selector's result.
class LoserSelectorFromGen
  # The linguistic system providing the GEN function.
  attr_reader :system

  # the comparer for comparing pairs of candidates.
  attr_reader :comparer

  # Constructs a new LoserSelectorFromGen object, given a _system_ and
  # a _comparer_.
  #
  # === Parameters
  # * _system_ - provides access to GEN for the linguistic system.
  # * _comparer_ - compares two candidates with respect to ranking
  #   information.
  # :call-seq:
  #   LoserSelectorFromGen.new(system, comparer) -> selector
  #--
  # selector_class is a dependency injection used for testing.
  def initialize(system, comparer,
                 selector_class: LoserSelectorFromCompetition)
    @system = system
    @comparer = comparer
    @selector = selector_class.new(comparer)
  end

  # Returns the informative loser from among the candidates generated
  # by GEN for the winner's input. Returns nil if no informative loser
  # is found.
  # :call-seq:
  #   select_loser(winner, ranking_info) -> candidate or nil
  def select_loser(winner, ranking_info)
    # Obtain the competition from GEN.
    competition = @system.gen(winner.input)
    # Return whatever @selector.select_loser_from_competition returns.
    @selector.select_loser_from_competition(winner, competition,
                                            ranking_info)
  end
end
