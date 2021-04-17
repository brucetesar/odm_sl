# frozen_string_literal: true

# Author: Bruce Tesar

require 'lexicon'
require 'morph_word'
require 'morpheme'

module ODL
  # An object of this class is able to generate a set of competitions,
  # one for each morphword that meets specifications. The presumed
  # morphological categories come from the class Morpheme, and are:
  # * Morpheme::ROOT
  # * Morpheme::SUFFIX
  # * Morpheme::PREFIX
  class StressLengthDataGenerator
    # Returns a new Stress-Length data generator object.
    # :call-seq:
    #   new(lexentry_generator, comp_generator) -> data_generator
    #--
    # The named parameters _lexicon_class_ and _morphword_class_ are
    # dependency injections used for testing.
    def initialize(lexentry_generator, comp_generator,
                   lexicon_class: Lexicon, morphword_class: MorphWord)
      @lexentry_generator = lexentry_generator
      @comp_generator = comp_generator
      # Dependency injection instance variables
      @lexicon_class = lexicon_class
      @morphword_class = morphword_class
    end

    # Returns a list of competitions. The lexical entries corresponding
    # to the possible underlying forms for 1-syllable roots and 1-syllable
    # suffixes are created. Then all possible root-suffix pairs are
    # constructed, and a morphword is constructed for each such pair.
    # Finally, a separate competition is constructed for each morphword,
    # a a list of the competitions is returned.
    def generate_competitions_1r1s
      # generate the morphemes
      roots = @lexentry_generator.generate_morphemes(1, Morpheme::ROOT, 0)
      suffixes =
        @lexentry_generator.generate_morphemes(1, Morpheme::SUFFIX, 0)
      # create a temporary lexicon, adding all lexical entries.
      lexicon = @lexicon_class.new
      roots.each{ |root_le| lexicon.add(root_le) }
      suffixes.each{ |suf_le| lexicon.add(suf_le) }
      # Morphology: create all combinations of one root and one suffix
      word_parts = roots.product(suffixes)
      # Next line: how to include free roots as (monomorphemic) words
      # word_parts += roots.product()
      words = word_parts.map do |parts|
        # Add the morphemes of the combination to a new morphological word
        parts.inject(@morphword_class.new){ |w, le| w.add(le.morpheme); w}
      end
      @comp_generator.competitions_from_morphwords(words, lexicon)
    end
  end
end
