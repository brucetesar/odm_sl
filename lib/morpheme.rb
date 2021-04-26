# frozen_string_literal: true

# Author: Bruce Tesar

# A morpheme has a label and a type (root, suffix, or prefix). Morpheme
# objects must be given both the label and type upon construction, and
# are immediately frozen; they should be unique (no two morphemes should
# have the same label, let alone same label and same type).
class Morpheme
  # morpheme type ROOT
  ROOT = :root
  # morpheme type PREFIX
  PREFIX = :prefix
  # morpheme type SUFFIX
  SUFFIX = :suffix

  # The morpheme's label. It is frozen, and cannot be modified.
  attr_reader :label

  # The morpheme's morphological type.
  attr_reader :type

  # Returns a morpheme with the given label and of the given type.
  # The constructor makes a duplicate of the label, and then freezes
  # it, so that the label cannot be altered later. The morpheme object
  # itself is also frozen upon construction.
  # :call-seq:
  #   new(label, type) -> morpheme
  def initialize(label, type)
    @label = label.dup
    case type
    when ROOT, PREFIX, SUFFIX
      @type = type
    else
      raise 'morpheme type parameter is not a valid morph type.'
    end
    freeze
    @label.freeze
  end

  # Returns true if the morphemes are equivalent, false otherwise.
  # Two morphemes are equivalent if they have the same label and type.
  # :call-seq:
  #   morpheme == obj -> boolean
  def ==(other)
    (@label == other.label) && (@type == other.type)
  end

  # Returns true if the morphemes are equivalent, false otherwise.
  # Two morphemes are equivalent if they have the same label and type.
  # :call-seq:
  #   eql?(obj) -> boolean
  def eql?(other)
    self == other
  end

  # The hash function for a morpheme is the hash value of its label.
  # Ordinarily, the same morpheme shouldn't appear more than once
  # (at least in the same list), so different morphemes will likely
  # have different hash values.
  # :call-seq:
  #   hash() -> hash_value
  def hash
    @label.hash
  end

  # Returns true if the morpheme is of type root.
  def root?
    @type == ROOT
  end

  # Returns true if the morpheme is of type prefix.
  def prefix?
    @type == PREFIX
  end

  # Returns true if the morpheme is of type suffix.
  def suffix?
    @type == SUFFIX
  end

  # Returns the string representation of the label.
  def to_s
    @label
  end
end
