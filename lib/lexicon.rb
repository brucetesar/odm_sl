# frozen_string_literal: true

# Author: Bruce Tesar

require 'morpheme'

# A lexicon is a list of lexical entries.
class Lexicon < Array
  # Returns new lexicon object.
  # :call-seq:
  #   new() -> lexicon
  def initialize; end

  # Returns a duplicate copy of the lexicon. The copy of the lexicon contains
  # duplicated copies of the lexical entries of the lexicon. Altering a lexical
  # entry in the duplicate will not alter the corresponding lexical entry
  # in the original.
  def dup
    copy = Lexicon.new
    each { |e| copy.add(e.dup) }
    copy
  end

  # Adds a lexical entry to the lexicon. Returns a reference to the lexicon.
  def add(entry)
    push entry
    self
  end

  # Returns the underlying form for the given morpheme.
  # Returns nil if the morpheme has no entry.
  def get_uf(morph)
    lex_entry = find { |entry| entry.morpheme == morph } # get the lexical entry
    return nil if lex_entry.nil?

    lex_entry.uf # return the underlying form
  end

  # Returns an array of all the lexical entries containing morphemes
  # of type prefix.
  def get_prefixes
    find_all { |entry| entry.type == Morpheme::PREFIX }
  end

  # Returns an array of all the lexical entries containing morphemes
  # of type suffix.
  def get_suffixes
    find_all { |entry| entry.type == Morpheme::SUFFIX }
  end

  # Returns an array of all the lexical entries containing morphemes
  # of type root.
  def get_roots
    find_all { |entry| entry.type == Morpheme::ROOT }
  end

  # Returns a string representation of the lexicon, with the lexical
  # entries grouped by morpheme type.
  def to_s
    prefixes = get_prefixes
    roots = get_roots
    suffixes = get_suffixes
    out_str = prefixes.join('  ')
    out_str += "\n" unless prefixes.empty?
    out_str += roots.join('  ')
    out_str += "\n" unless roots.empty?
    out_str += suffixes.join('  ')
    out_str += "\n" unless suffixes.empty?
    out_str
  end
end
