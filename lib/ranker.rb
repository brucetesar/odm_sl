# frozen_string_literal: true

# Author: Bruce Tesar

require 'rcd_runner'

# Objects of class Ranker respond to get_hierarchy(ercs) by returning
# a constraint hierarchy consistent with _ercs_. The standard use case
# is in circumstances where the user is confident that their _ercs_ are
# consistent, and all they are interested in the hierarchy for _ercs_
# with some specific ranking bias. Ranker encapsulates the calling
# of RCD and the extracting of the hierarchy from the information
# returned by running RCD.
class Ranker
  # Returns a ranker object which will construct a constraint hierarchy
  # consistent with a list of ercs, in accordance with the ranking
  # bias embedded in the _rcd_runner_. If no runner is provided,
  # the default runner is biased to rank all constraints as high as
  # possible.
  # ==== Parameters
  # * rcd_runner - object responding to \#run_rcd(ercs) with an Rcd
  #   object containing the results of running RCD on _ercs_.
  # :call-seq:
  #   Ranker.new -> ranker
  #   Ranker.new(rcd_runner) -> ranker
  def initialize(rcd_runner = RcdRunner.new)
    @rcd_runner = rcd_runner
  end

  # Returns a constraint hierarchy consistent with _ercs_, subject to
  # the ranking bias of the embedded RCD runner.
  # If the _ercs_ are collectively inconsistent, a RuntimeError is raised.
  def get_hierarchy(ercs)
    rcd = @rcd_runner.run_rcd(ercs)
    raise 'Ranker: the ERCs are inconsistent' unless rcd.consistent?

    rcd.hierarchy
  end
end
