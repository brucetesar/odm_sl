# frozen_string_literal: true

# Author: Bruce Tesar

# An Output is a list of correspondence elements, with an associated
# morphological word.
class Output < Array
  # the morphword associated with the output.
  attr_accessor :morphword

  # A newly created output is empty, with no morphological word, so that
  # it can be built up piece by piece.
  def initialize
    @morphword = nil
  end

  # Returns a copy of the output, containing a duplicate of each
  # correspondence element and a duplicate of the morphological word.
  def dup
    # Call Array#map to get an array of dups of the elements, and add
    # them to a new Output.
    copy = Output.new.concat(super.map(&:dup))
    copy.morphword = @morphword.dup unless @morphword.nil?
    copy
  end

  # Two outputs are the same if they contain equivalent elements.
  # The morphological words are *not* checked for equality.
  # Equivalent to eql?().
  def ==(other)
    return false unless super

    true
  end

  # Two outputs are the same if they contain equivalent elements.
  # The morphological words are *not* checked for equality.
  # Equivalent to ==().
  def eql?(other)
    self == other
  end

  # Returns a string containing the to_s() of each element in the output.
  def to_s
    join
  end

  # Determines whether there is main stress in the output.
  def main_stress?
    any?(&:main_stress?)
  end
end
