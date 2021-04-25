# frozen_string_literal: true

# Author: Bruce Tesar

# An Output is a list of correspondence elements, with an associated
# morphological word.
class Output < Array
  # The morphword associated with the output.
  attr_accessor :morphword

  # Returns a new output object, empty and with no morphological word.
  # :call-seq:
  #   new() -> output
  def initialize
    @morphword = nil
  end

  # Returns a duplicate of the output, containing a duplicate of each
  # correspondence element and a duplicate of the morphological word.
  # :call-seq:
  #   dup() -> output
  def dup
    # Call Array#map to get an array of dups of the elements, and add
    # them to a new Output.
    copy = Output.new.concat(super.map(&:dup))
    copy.morphword = @morphword.dup
    copy
  end

  # Two outputs are the same if they contain equivalent elements.
  # The morphological words are *not* checked for equality.
  # Equivalent to eql?().
  # :call-seq:
  #   output == obj -> boolean
  def ==(other)
    return false unless size == other.size

    each_index { |idx| return false unless self[idx] == other[idx] }

    true
  end

  # Two outputs are the same if they contain equivalent elements.
  # The morphological words are *not* checked for equality.
  # Equivalent to ==().
  # :call-seq:
  #   eql?(other) -> boolean
  def eql?(other)
    self == other
  end

  # Returns a string containing the to_s() of each element in the output,
  # concatenated in order with no separators.
  # :call-seq:
  #   to_s() -> string
  def to_s
    join
  end

  # Returns true if one of the syllables has main stress, false otherwise.
  # :call-seq:
  #   main_stress?() -> boolean
  def main_stress?
    any?(&:main_stress?)
  end
end
