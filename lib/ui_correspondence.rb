# frozen_string_literal: true

# Author: Bruce Tesar

# A UI correspondence relates corresponding underlying-input elements.
# The underlying elements belong to the lexical entries of the morphemes
# for the input.
#
# NOTE: a UI correspondence is specific to a particular instance of
# a particular input. References to the actual
# elements of the underlying form and input are stored in the
# correspondence, and retrieval is based on object identity, using
# #equal?(), NOT #==. This is important: two phonologically identical
# elements could have separate existence in the same input (and even
# belong to the same morpheme).
#---
# Each pair is a size 2 array with the first element the underlying
# correspondent and the second element the input correspondent.
class UICorrespondence
  # The index in a correspondence pair for the underlying element.
  UF = 0 # :nodoc:

  # The index in a correspondence pair for the input element.
  IN = 1 # :nodoc:

  # Returns an empty UICorrespondence.
  # :call-seq:
  #   new() -> correspondence
  def initialize
    @pair_list = []
  end

  # Adds a correspondence pair indicating that _uf_el_ and _in_el_
  # are UI correspondents. Returns a reference to self.
  # :call-seq:
  #   add_corr(uf_el, in_el) -> self
  def add_corr(uf_el, in_el)
    pair = []
    pair[UF] = uf_el
    pair[IN] = in_el
    @pair_list << pair
    self
  end

  # Returns the number of correspondence pairs in the relation.
  # :call-seq:
  #   size() -> int
  def size
    @pair_list.size
  end

  # Returns true if underlying element _uf_el_ has an input
  # correspondent. Returns false otherwise.
  # :call-seq:
  #   in_corr?(uf_el) -> boolean
  def in_corr?(uf_el)
    @pair_list.any? { |pair| pair[UF].equal?(uf_el) }
  end

  # Returns true if input element _in_el_ has an underlying
  # correspondent (in the lexicon). Returns false otherwise.
  # :call-seq:
  #   under_corr?(in_el) -> boolean
  def under_corr?(in_el)
    @pair_list.any? { |pair| pair[IN].equal?(in_el) }
  end

  # Returns the input correspondent for underlying element _uf_el_.
  # If _uf_el_ has no input correspondent, then nil is returned.
  #
  # If _uf_el_ has more than one correspondent, the first one listed
  # in the correspondence relation (unpredictable) is returned. *Note*:
  # if multiple correspondence is allowed, a different implementation
  # of the correspondence relation should be used.
  # :call-seq:
  #   in_corr(uf_el) -> in_el
  def in_corr(uf_el)
    first_pair = @pair_list.find { |pair| pair[UF].equal?(uf_el) }
    return nil if first_pair.nil?

    first_pair[IN]
  end

  # Returns the underlying correspondent for input element _in_el_.
  # If _in_el_ has no underlying correspondent, then nil is returned.
  #
  # If _in_el_ has more than one correspondent, the first one listed
  # in the correspondence relation (unpredictable) is returned. *Note*:
  # if multiple correspondence is allowed, a different implementation
  # of the correspondence relation should be used.
  # :call-seq:
  #   under_corr(in_el) -> uf_el
  def under_corr(in_el)
    first_pair = @pair_list.find { |pair| pair[IN].equal?(in_el) }
    return nil if first_pair.nil?

    first_pair[UF]
  end
end
