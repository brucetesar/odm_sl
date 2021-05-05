# frozen_string_literal: true

# Author: Bruce Tesar

# Implements a ranking bias for RCD in which all constraints are ranked
# as high as possible. This is accomplished by choosing, at each step,
# to rank all of the rankable constraints.
class RankingBiasAllHigh
  # Returns a new RankingBiasAllHigh object.
  # :call-seq:
  #   new -> ranking_bias
  def initialize; end

  # Returns all of the rankable constraints to be ranked in the next
  # stratum, that is, it returns the parameter _rankable_ unaltered.
  def choose_cons_to_rank(rankable, _rcd)
    rankable
  end
end
