# frozen_string_literal: true

# Author: Bruce Tesar

# A stratified constraint hierarchy. The top stratum of the hierarchy
# is first in the list, and so forth. Each stratum is a list of constraints.
class Hierarchy < Array
  # Returns a duplicate hierarchy, with distinct stratum objects,
  # but containing references to the very same constraint objects.
  def dup
    copy = Hierarchy.new
    each { |strat| copy << strat.dup }
    copy
  end

  # Returns a string representation of the hierarchy, with strata
  # delimited by square brackets.
  #
  # Example: "[c1] [c2 c3] [c4]"
  def to_s
    # strata_strings accumulates string reps. of the strata
    strata_strings = map do |stratum|
      # con_strings accumulates string reps. of the constraints
      con_strings = stratum.map(&:to_s)
      # The '[' must be duplicated, because string literals are frozen
      # and cannot be appended to.
      # Constraints are separated by a space via #join(' ').
      '['.dup << con_strings.join(' ') << ']'
    end
    strata_strings.join(' ') # separates the strata with spaces.
  end
end
