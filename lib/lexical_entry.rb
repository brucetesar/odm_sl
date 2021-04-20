# frozen_string_literal: true

# Author: Bruce Tesar

# A lexical entry pairs a morpheme with an underlying form.
class LexicalEntry
  # The morpheme of the lexical entry.
  attr_reader :morpheme

  # Returns a lexical entry with the given morpheme and underlying form.
  # :call-seq:
  #   new(morpheme, underlying_form) -> lexical_entry
  def initialize(morpheme, underlying_form)
    @morpheme = morpheme
    @underlying_form = underlying_form
  end

  # Returns a duplicate lexical entry. The morpheme object in the
  # duplicate entry is identical to the original. The underlying form
  # of the duplicate is itself a duplicate of the underlying form of
  # the original.
  # :call-seq:
  #   dup() -> lexical_entry
  def dup
    LexicalEntry.new(@morpheme, @underlying_form.dup)
  end

  # Returns the label of the morpheme in this lexical entry.
  def label
    @morpheme.label
  end

  # Returns the morphological type of the morpheme in this lexical entry.
  def type
    @morpheme.type
  end

  # Returns the underlying form of the morpheme in this lexical entry.
  def uf
    @underlying_form
  end

  # Returns a string giving the morpheme label and the underlying form.
  def to_s
    "#{@morpheme.label} #{@underlying_form}"
  end
end
