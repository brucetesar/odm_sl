# frozen_string_literal: true

# Author: Bruce Tesar

require 'erc_list'
require 'lexicon'

# A grammar consists of a reference to a linguistic system,
# a list of ERCs, and a lexicon.
class Grammar
  # The optional label assigned to the grammar.
  attr_accessor :label

  # The list of ercs defining the ranking information of the grammar.
  attr_reader :erc_list

  # The lexicon for the grammar.
  attr_reader :lexicon

  # The linguistic system associated with this grammar.
  attr_reader :system

  # :call-seq:
  #   Grammar.new(mysystem) -> grammar
  #   Grammar.new(mysystem, erc_list: mylist, lexicon: mylexicon) -> grammar
  #
  # The first returns a grammar with an empty ERC list and an empty
  # lexicon.
  # The second returns a grammar with ERC list _mylist_ and lexicon
  # _mylexicon_.
  def initialize(system, erc_list: nil, lexicon: Lexicon.new)
    @system = system
    # If no ERC list was provided, create an empty one.
    @erc_list = erc_list
    @erc_list ||= ErcList.new(@system.constraints)
    self.label = 'Grammar'
    @lexicon = lexicon
  end

  # Adds an erc to the list.
  # Returns a reference to self (the grammar).
  def add_erc(erc)
    erc_list.add(erc)
    self
  end

  # Returns true if the ERC list is currently consistent; false otherwise.
  def consistent?
    erc_list.consistent?
  end

  # Returns a deep copy of the grammar, with a duplicates of the lexicon.
  # The duplicate of the lexicon contains duplicates of the lexical entries,
  # and the duplicate lexical entries contain duplicates of the underlying
  # forms but references to the very same morpheme objects.
  def dup
    self.class.new(system, erc_list: erc_list.dup, lexicon: lexicon.dup)
  end

  # Returns a copy of the grammar, with a copy of the ERC list, and
  # a reference to the very same lexicon object.
  def dup_same_lexicon
    self.class.new(system, erc_list: erc_list.dup, lexicon: lexicon)
  end

  # Returns the underlying form for the given morpheme, as stored in
  # the grammar's lexicon. Returns nil if the morpheme does not appear
  # in the lexicon.
  def get_uf(morph)
    @lexicon.get_uf(morph)
  end

  # Parses the given output, returning the full word (with input,
  # correspondence). The input features match the lexicon for set features,
  # and are unset in the input for features unset in the lexicon.
  def parse_output(out)
    system.parse_output(out, lexicon)
  end
end
