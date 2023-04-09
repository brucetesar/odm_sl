# frozen_string_literal: true

# Author: Bruce Tesar

require 'lexicon'
require 'morph_word'
require 'morpheme'

module ODL
  # An object of this class is able to generate a set of competitions,
  # one for each morphword that meets specifications. The presumed
  # morphological categories come from the class Morpheme, and are:
  # * Morpheme::PREFIX
  # * Morpheme::ROOT
  # * Morpheme::SUFFIX
  class StressLengthDataGenerator
    # Internal alias for Morpheme::ROOT.
    ROOT = Morpheme::ROOT

    # Internal alias for Morpheme::SUFFIX.
    SUFFIX = Morpheme::SUFFIX

    # Internal alias for Morpheme::PREFIX.
    PREFIX = Morpheme::PREFIX

    # Returns a new Stress-Length data generator object.
    # === Parameters
    # * lexentry_generator - generates lexical entries for possible
    #   underlying forms of morphemes.
    # * comp_generator - generates a set of competitions for a given
    #   set of morphwords, given lexical entries for the morphemes.
    # :call-seq:
    #   new(lexentry_generator, comp_generator) -> data_generator
    #--
    # The named parameters _lexicon_class_ and _morphword_class_ are
    # dependency injections used for testing.
    def initialize(lexentry_generator, comp_generator,
                   lexicon_class: nil, morphword_class: nil)
      @lexentry_generator = lexentry_generator
      @comp_generator = comp_generator
      @lexicon_class = lexicon_class || Lexicon
      @morphword_class = morphword_class || MorphWord
    end

    # Returns a list of competitions. The lexical entries corresponding
    # to the possible underlying forms for 1-syllable roots and 1-syllable
    # suffixes are created. Then all possible root-suffix pairs are
    # constructed, and a morphword is constructed for each such pair.
    # Finally, a separate competition is constructed for each morphword,
    # and a list of the competitions is returned.
    def generate_competitions_1r1s
      # generate the morphemes
      roots = @lexentry_generator.lexical_entries(1, ROOT, 0)
      suffixes = @lexentry_generator.lexical_entries(1, SUFFIX, 0)
      # create a temporary lexicon, adding all lexical entries.
      lexicon = @lexicon_class.new
      roots.each { |root_le| lexicon.add(root_le) }
      suffixes.each { |suf_le| lexicon.add(suf_le) }
      # Construct morphwords for each root+suffix combination
      words = combine_morphemes(roots, suffixes)
      # Generate a competition for each morphword; return a list of them.
      @comp_generator.competitions(words, lexicon)
    end

    # Temporary method to generate words with roots of both 1 and 2
    # syllables, in combination with 1-syllable suffixes.
    # TODO: replace with a parameterized #generate_competitions method.
    def generate_competitions_2r1s
      # generate the morphemes
      roots = @lexentry_generator.lexical_entries(2, ROOT, 0)
      suffixes = @lexentry_generator.lexical_entries(1, SUFFIX, 0)
      # create a temporary lexicon, adding all lexical entries.
      lexicon = @lexicon_class.new
      roots.each { |root_le| lexicon.add(root_le) }
      suffixes.each { |suf_le| lexicon.add(suf_le) }
      # Construct morphwords for each root+suffix combination
      words = combine_morphemes(roots, suffixes)
      # Generate a competition for each morphword; return a list of them.
      @comp_generator.competitions(words, lexicon)
    end

    # Constructs all root+suffix combinations of _roots_ and _suffixes_,
    # representing each combination as a morphword. Returns an array
    # of morphwords.
    def combine_morphemes(roots, suffixes)
      # Morphology: create all combinations of one root and one suffix
      word_parts = roots.product(suffixes)
      # Next line: how to include free roots as (monomorphemic) words
      # word_parts += roots.product()
      word_parts.map do |parts|
        # Add the morphemes of the combination to a new morphological word
        parts.each_with_object(@morphword_class.new) do |le, mw|
          mw.add(le.morpheme)
        end
      end
    end
    private :combine_morphemes
  end
end
