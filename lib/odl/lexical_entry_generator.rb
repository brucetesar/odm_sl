# frozen_string_literal: true

# Author: Bruce Tesar

require 'morpheme'
require 'lexical_entry'

module ODL
  # A lexical entry generator has methods to generate sets of lexical
  # entries meeting given specifications.
  class LexicalEntryGenerator
    # Returns a new lexical entry generator object.
    # === Parameters
    # * uf_generator - object capable of generating a set of underlying
    #   forms of a specified length.
    # :call-seq:
    #   new(uf_generator) -> generator
    def initialize(uf_generator)
      @uf_generator = uf_generator
    end

    # Returns an array of lexical entries for the possible morphemes
    # of morphological type _type_, with underlying form length
    # _uf_length_. Each morpheme is assigned a label consisting of:
    # * a letter representing the morpheme type (r for root, s for
    #   suffix, p for prefix).
    # * a distinct ID number, with _id_base_ providing the base (the
    #   first generated morpheme gets id number _id_base_ + 1, the next
    #   generated morpheme gets id number _id_base_ + 2, etc.).
    # The morphological _type_ should be one of the type constants
    # defined in the class Morpheme:
    # * Morpheme::ROOT
    # * Morpheme::PREFIX
    # * Morpheme::SUFFIX
    # Raises a RuntimeError if _type_ is not recognized.
    # :call-seq:
    #   lexical_entries(uf_length, type, id_base) -> array
    def lexical_entries(uf_length, type, id_base)
      id_number = id_base
      label = morpheme_label(type)
      le_list = []
      @uf_generator.underlying_forms(uf_length) do |uf|
        id_number += 1
        morph = Morpheme.new("#{label}#{id_number}", type)
        uf.each { |el| el.set_morpheme(morph) }
        le_list << Lexical_Entry.new(morph, uf)
      end
      le_list
    end

    # Returns the single character string corresponding to _type_.
    # Raises a RuntimeError if _type_ is not recognized.
    def morpheme_label(type)
      case type
      when Morpheme::ROOT then 'r'
      when Morpheme::PREFIX then 'p'
      when Morpheme::SUFFIX then 's'
      else raise 'LexicalEntryGenerator: unrecognized morpheme type'
      end
    end
    private :morpheme_label
  end
end
