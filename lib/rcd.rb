# frozen_string_literal: true

# Author: Bruce Tesar

require 'hierarchy'

# Implements Recursive Constraint Demotion (RCD).
# An Rcd object takes a list of ERCs, runs RCD, and stores the
# constructed hierarchy.
#
# In the case of inconsistency, the unranked constraints and the remaining
# unexplained ERCs are also stored. The stored hierarchy contains the
# rankable constraints as ranked by RCD, with the unrankable constraints in
# an added bottom stratum.
#
# ===References
#
# Tesar 1995. Computational Optimality Theory. ROA-90.
#
# Tesar 1997. Multi-Recursive Constraint Demotion. ROA-197.
#
# Tesar & Smolensky 2000. <em>Learnability in Optimality Theory</em>. MIT Press.
class Rcd
  # A list of the constraints.
  attr_reader :constraint_list

  # The hierarchy of constraints ranked by RCD. If the set of
  # Ercs is inconsistent, this will not include all of the constraints;
  # the rest of the constraints will be returned by #unranked.
  attr_reader :ranked

  # An array of constraints that remain unranked after the
  # completion of RCD. This list will be empty unless the set of Ercs
  # is inconsistent.
  attr_reader :unranked

  # A "stratified" list of explained ERCs, as an array of arrays.
  # The first "stratum" contains the ERCs explained by the constraints in
  # the first stratum of the constraint hierarchy, and so forth.
  attr_reader :ex_ercs

  # A list of unexplained ERCs, as an array.
  # When the original list of ERCs is consistent, this array
  # will either be empty or contain only trivial ERCs (all e).
  attr_reader :unex_ercs

  # Returns an object containing the results of running Recursive
  # Constraint Demotion on the ERC list +erc_list+.
  #--
  # The constructor copies the ERCs of the +erc_list+ parameter to the internal
  # array @ercs. Thus, it shouldn't matter if the parameter list
  # subsequently changes state, so long as the constraint list
  # and ERC objects are not themselves directly altered.
  #++
  # :call-seq:
  #   Rcd.new(erc_list) -> rcd
  def initialize(erc_list)
    @ercs = [] # an array, no matter the class of erc_list
    erc_list.each { |erc| @ercs << erc }
    @constraint_list = erc_list.constraint_list
    # Initialize the instance variables that are altered within run_rcd.
    # Initially, all ERCs are unexplained and all constraints are unranked.
    @unranked = constraint_list
    @ranked = Hierarchy.new # initially empty
    @unex_ercs = @ercs
    @ex_ercs = []
    # Run RCD to construct the hierarchy
    run_rcd
  end

  # Returns a list of all the ERCs, as an ErcList object.
  def erc_list
    new_erc_list = ErcList.new
    new_erc_list.add_all(@ercs)
    new_erc_list
  end

  # Returns true if the set of ERCs is consistent; returns false otherwise.
  def consistent?
    @unranked.empty?
  end

  # Returns a full constraint hierarchy. If the ERCs are inconsistent,
  # Then the hierarchy has the ranked constraints constructed by RCD, with
  # the unranked constraints added as a bottom stratum.
  def hierarchy
    hierarchy = @ranked.dup
    # Add any unranked constraints as a bottom stratum
    (hierarchy << unranked) unless unranked.empty?
    hierarchy
  end

  # A constraint is rankable with respect to a set of ERCs if the constraint
  # does not prefer the loser in any of the ERCs.
  #
  # :call-seq:
  #   rankable?(constraint, erc_list) -> boolean
  def rankable?(con, ercs)
    ercs.none? { |erc| erc.l?(con) }
  end
  protected :rankable?

  # An ERC is explained with respect to a set of constraints if at least
  # one of the constraints prefers the winner.
  #
  # :call-seq:
  #   explained?(erc, constraint_list) -> boolean
  def explained?(erc, constraints)
    constraints.any? { |con| erc.w?(con) }
  end
  protected :explained?

  # Executes Recursive Constraint Demotion (RCD) on the list of ERCs.
  # If the ERCs are consistent, @ranked will contain the computed hierarchy,
  # and @unranked and @unex_ercs will be empty.
  # If the ERCs are inconsistent, @unranked will contain the unrankable
  # constraints, and @unex_ercs will contain the unexplainable, collectively
  # inconsistent ERCs.
  def run_rcd
    # Find the initially rankable constraints
    rankable = @unranked.find_all { |con| rankable?(con, @unex_ercs) }
    until rankable.empty? # repeat until no more constraints are rankable
      stratum = choose_cons_to_rank(rankable)
      rank_next_stratum(stratum)
      move_newly_explained_ercs(stratum)
      # Find newly rankable constraints
      rankable = @unranked.find_all { |con| rankable?(con, @unex_ercs) }
    end
  end
  protected :run_rcd

  # Places the next stratum of constraints into the developing hierarchy,
  # and removes them from the list of unranked constraints.
  def rank_next_stratum(stratum)
    @ranked << stratum
    @unranked -= stratum
  end
  protected :rank_next_stratum

  # Identifies the ERCs explained by the newly ranked constraints, and
  # moves those ERCs from the unexplained list to the explained list.
  def move_newly_explained_ercs(stratum)
    # NOTE: resist the temptation to identify the newly explained ERCs,
    # and then remove them from unexplained ERC list. That kind of
    # removal involves comparing for equality, and a list of ERCs can
    # end up containing ERC objects and Win_lose_pair objects, making
    # equality tests complicated. Partitioning on the basis of
    # #explained? avoids #eql? comparisons.
    #
    # Separate out the newly explained ERCs
    explained, @unex_ercs =
      @unex_ercs.partition { |e| explained?(e, stratum) }
    # Store the newly explained ERCs as the next "ERC stratum"
    @ex_ercs << explained
  end
  protected :move_newly_explained_ercs

  # This method defines the ranking bias. The default here is to rank all
  # constraints as high as possible, as per original RCD. This method can
  # be overridden in subclasses to define other biases (like faithfulness
  # as low as possible, as in BCD).
  # It is given an array of rankable constraints, and returns an array of
  # constraints to actually be placed into the hierarchy.
  #
  # :call-seq:
  #   choose_cons_to_rank(rankable_constraint_list) -> array
  def choose_cons_to_rank(rankable)
    rankable
  end
  protected :choose_cons_to_rank
end
