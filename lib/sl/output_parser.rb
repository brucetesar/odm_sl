# frozen_string_literal: true

# Author: Bruce Tesar

require 'underlying'
require 'lexical_entry'
require 'word'

module SL
  # Parses outputs into full words (input, output, IO correspondence) for
  # the linguistic system provided to the constructor.
  class OutputParser
    # Returns a new output parser.
    # :call-seq:
    #   new(system) -> parser
    def initialize(system)
      @system = system
    end

    # Returns a word (full structural description) for _output_ using
    # _lexicon_. The input constructed from the lexicon must stand in
    # 1-to-1 IO correspondence with _output_, otherwise an exception
    # is raised.
    def parse_output(output, lexicon)
      mw = output.morphword
      # Create new lexical entries for any morphemes that aren't currently
      # in the lexicon.
      add_new_morphemes(mw, output, lexicon)
      # Construct the input form
      input = @system.input_from_morphword(mw, lexicon)
      # Create the new word, and its IO correspondence
      word = Word.new(@system, input, output)
      create_io_correspondence(word)
      # compute the number of violations of each constraint
      word.eval
      word
    end

    # Checks each morpheme of _morphword_, and creates a new lexical entry
    # if the morpheme does not already have one in _lexicon_.
    # Each new lexical entry has the same number of syllables as that
    # morpheme has in _output_, and all features are unset.
    # :call-seq:
    #   add_new_morpheme(morphword, output, lexicon) -> nil
    def add_new_morphemes(morphword, output, lexicon)
      morphword.each do |m|
        # Skip to next if this morpheme already has a lexical entry
        next if lexicon.any? { |entry| entry.morpheme == m }

        under = Underlying.new
        # create a new UF syllable for each syllable of m in the output
        syls_of_m = output.find_all { |syl| syl.morpheme == m }
        syls_of_m.each do |_x|
          # The correspondence element class is the syllable class.
          under << @system.corr_element_class.new.set_morpheme(m)
        end
        lexicon << LexicalEntry.new(m, under)
      end
      nil
    end
    private :add_new_morphemes

    # Creates a bijective IO correspondence for _word_. Returns nil.
    def create_io_correspondence(word)
      input = word.input
      output = word.output
      # Sanity check: 1-to-1 corresp. requires same sizes.
      if input.size != output.size
        raise "OutputParser: Input size #{input.size} != " \
              "output size #{output.size}."
      end
      # Iterate over successive input and output syllables, adding each
      # pair to the word's correspondence relation.
      input.each_with_index do |in_syl, idx|
        out_syl = output[idx]
        word.add_to_io_corr(in_syl, out_syl)
        # Corresponding morphemes must be affiliated with the same morpheme.
        if in_syl.morpheme != out_syl.morpheme
          raise "Input syllable morph #{in_syl.morpheme.label} != " \
                "output syllable morph #{out_syl.morpheme.label}"
        end
      end
      nil
    end
    private :create_io_correspondence
  end
end
