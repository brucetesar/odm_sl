# frozen_string_literal: true

# Author: Bruce Tesar

# A MorphWord represents the morphological structure of a word.
# It contains the morphemes of the word in order.
#
# Includes the mixin Enumerable.
#
# Although a MorphWord need not be constructed with a root, the first
# morpheme added to the word must be a root, and a word can only have
# one root. The order of the morphemes presumes that the word is put
# together from the inside out: the first prefix added will immediately
# precede the root, the second prefix added will appear immediately before
# that, etc., with the beginning of the word consisting of the last prefix
# added (unless no prefixes are added). Similarly, the first suffix added
# appears immediately after the root, and so forth, with the end of the
# word consisting of the last suffix added (unless no suffixes are added).
class MorphWord
  include Enumerable

  # Returns a new morphological word. If a root is provided as a parameter,
  # it is added as the root of the word. Otherwise, the word is initially
  # empty. A RuntimeError exception is raised if the constructor is given
  # a morpheme that is not a root.
  # :call-seq:
  #   new() -> morph_word
  #   new(morph) -> morph_word
  def initialize(morph = nil)
    @word = []
    @root_added = false
    return if morph.nil?

    msg = 'MorphWord.initialize: The first morpheme added must be a root.'
    raise msg unless morph.root?

    @word.push(morph)
    @root_added = true
  end

  # Returns the number of morphemes in the word.
  # :call-seq:
  #   morph_count() -> int
  def morph_count
    @word.size
  end

  # Adds the morpheme _morph_ to the word. The morpheme must be an
  # accepted morpheme type (root, prefix, suffix). Returns a
  # reference to self.
  #
  # A RuntimeError is raised if an attempt is made to add a root to word
  # already containing a root, or a non-root to a word that does not
  # already contain a root.
  # :call-seq:
  #   add(morph) -> morph_word
  def add(morph)
    check_root_conditions(morph)
    if morph.root?
      @word.push(morph)
      @root_added = true
    elsif morph.prefix?
      @word.unshift(morph)
    elsif morph.suffix?
      @word.push(morph)
    else
      raise 'MorphWord.add: invalid morpheme type.'
    end
    self
  end

  # Checks the root conditions: cannot add a second root, cannot
  # affix to a rootless morphword. Called by #add().
  def check_root_conditions(morph)
    msg1 = 'MorphWord.add: Cannot add a second root.'
    raise msg1 if morph.root? && @root_added

    msg2 = 'MorphWord.add: Cannot add an affix to a word without a root.'
    raise msg2 if !morph.root? && !@root_added

    true
  end
  private :check_root_conditions

  # Applies the given code block to each morpheme in the word in order of
  # precedence (left to right). Returns a reference to self.
  def each(&block) # :yields: morpheme
    @word.each(&block)
    self
  end

  # Returns a duplicate of the morphword.
  # :call-seq:
  #   dup() -> morph_word
  #--
  # Uses protected methods #word= and #root_added=, to gain assignment
  # access to those internal fields in the duplicate.
  def dup
    copy = MorphWord.new
    copy.word = @word.dup
    copy.root_added = @root_added
    copy
  end

  # Returns true if the two morph_words consist of equivalent
  # morphemes in the identical sequence.
  # Equivalent to eql?(other).
  # :call-seq:
  #   morph_word == obj -> boolean
  def ==(other)
    # Must have the same quantity of morphemes
    return false unless morph_count == other.morph_count

    # Get external iterators over the morphemes of the words.
    # SyncEnumerator won't work here, because it requires []-style access.
    self_iter = to_enum
    other_iter = other.to_enum
    # Iterate over both morph_words simultaneously
    loop do
      self_morph = self_iter.next
      other_morph = other_iter.next
      # Order-matching morphemes must be the same
      return false unless self_morph == other_morph
    end
    true
  end

  # Returns true if the two morph_words consist of equivalent
  # morphemes in the identical sequence.
  # Equivalent to eql?(other).
  # :call-seq:
  #   eql?(obj) -> boolean
  def eql?(other)
    self == other
  end

  # Sets the root_added flag to the parameter _boolean_.
  # Protected: used in #dup.
  def root_added=(boolean)
    @root_added = boolean
  end
  protected :root_added=

  # Sets the word array to the parameter _word_.
  # Protected: used in #dup.
  def word=(word)
    @word = word
  end
  protected :word=

  # Returns a string representation of the morphemes in order, separated
  # by '-'.
  # :call-seq:
  #   to_s() -> string
  def to_s
    @word.map(&:label).join('-')
  end
end
