# frozen_string_literal: true

# Author: Bruce Tesar

# An IO correspondence relates corresponding input-output elements.
#
# NOTE: an IO correspondence is specific to a particular instance of
# a particular word. References to the actual
# elements of the input and output are stored in the correspondence,
# and retrieval is based on object identity, using .equal?(), NOT ==.
# This is important: two phonologically identical elements could have
# separate existence in the same input or output (and even belong to
# the same morpheme).
#---
# Each pair is a size 2 array with the first element the input
# correspondent and the second element the output correspondent.
class IOCorrespondence
  # The index (integer) in a correspondence pair for the input element.
  IN = 0 # :nodoc:

  # The index (integer) in a correspondence pair for the output element.
  OUT = 1 # :nodoc:

  # Returns an empty IOCorrespondence.
  # :call-seq:
  #   new() -> correspondence
  def initialize
    @pair_list = []
  end

  # Adds a correspondence pair indicating that _in_el_ and _out_el_
  # are IO correspondents. Returns a reference to self.
  # :call-seq:
  #   add_corr(in_el, out_el) -> self
  def add_corr(in_el, out_el)
    pair = []
    pair[IN] = in_el
    pair[OUT] = out_el
    @pair_list << pair
    self
  end

  # Returns the number of correspondence pairs in the relation.
  # :call-seq:
  #   size() -> int
  def size
    @pair_list.size
  end

  # Returns true if the output element _out_el_ has an input
  # correspondent, false otherwise.
  # :call-seq:
  #   in_corr?(out_el) -> boolean
  def in_corr?(out_el)
    @pair_list.any? { |pair| pair[OUT].equal?(out_el) }
  end

  # Returns true if the input element _in_el_ has an output
  # correspondent, false otherwise.
  # :call-seq:
  #   out_corr?(in_el) -> boolean
  def out_corr?(in_el)
    @pair_list.any? { |pair| pair[IN].equal?(in_el) }
  end

  # Returns the input correspondent for output element _out_el_.
  # If _out_el_. has no input correspondent, nil is returned.
  # If _out_el_. has more than one input correspondent, the first one
  # listed in the correspondence relation is returned.
  # :call-seq:
  #   in_corr(out_el) -> in_el
  def in_corr(out_el)
    first_pair = @pair_list.find { |pair| pair[OUT].equal?(out_el) }
    return nil if first_pair.nil?

    first_pair[IN]
  end

  # Returns the output correspondent for input element _in_el_.
  # If _in_el_ has no output correspondent, nil is returned.
  # If _in_el_ has more than one output correspondent, the first one
  # listed in the correspondence relation is returned.
  # :call-seq:
  #   out_corr(in_el) -> out_el
  def out_corr(in_el)
    first_pair = @pair_list.find { |pair| pair[IN].equal?(in_el) }
    return nil if first_pair.nil?

    first_pair[OUT]
  end
end
