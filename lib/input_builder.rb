# frozen_string_literal: true

# Author: Bruce Tesar

require 'input'

# Builds an input form by concatenating the correspondence elements of
# the underlying forms of morphemes, in order.
class InputBuilder
  # Returns a new input builder object.
  # :call-seq:
  #   new -> builder
  def initialize; end

  # Builds an input form from the morphemes of the morph_word _mwd_, using
  # the underlying forms stored in _lexicon_. It also constructs the
  # UI correspondence relation between the underlying forms and the input.
  # Returns the newly build input.
  # :call-seq:
  #   input_from_morphword(mwd, lexicon) -> input
  def input_from_morphword(mwd, lexicon)
    input = Input.new
    input.morphword = mwd
    # For each morpheme of the morph_word, in order
    mwd.each do |morph|
      lex_entry = lexicon.find { |entry| entry.morpheme == morph }
      check_lexical_entry(lex_entry, morph)
      # Iterate over the correspondence elements of the underlying form
      lex_entry.uf.each do |uf_element|
        # add a duplicate of the underlying element to input.
        in_element = uf_element.dup
        input.push(in_element)
        # add a correspondence between underlying and input elements.
        input.ui_corr.add_corr(uf_element, in_element)
      end
    end
    input
  end

  # Error-checks the lexical entry _lex_entry_ for the morpheme _morph_.
  # Raises an exception if:
  # * the morpheme has no lexical entry in the lexicon.
  # * the lexical entry has no underlying form.
  # Returns nil.
  def check_lexical_entry(lex_entry, morph)
    raise "Morpheme #{morph.label} has no lexical entry." if lex_entry.nil?

    if lex_entry.uf.nil?
      raise "The lexical entry for morpheme #{morph.label} " \
            'has no underlying form.'
    end
    nil
  end
  private :check_lexical_entry
end
