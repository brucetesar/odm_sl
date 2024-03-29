# frozen_string_literal: true

# Author: Bruce Tesar

require 'sl/syllable'
require 'sl/gen'
require 'sl/output_parser'
require 'sl/no_long'
require 'sl/wsp'
require 'sl/main_left'
require 'sl/main_right'
require 'sl/ident_stress'
require 'sl/ident_length'
require 'constraint'
require 'input_builder'
require 'odl/element_generator'
require 'odl/underlying_form_generator'
require 'odl/lexical_entry_generator'
require 'odl/competition_generator'
require 'odl/stress_length_data_generator'

# Module SL contains the linguistic system elements defining the
# Stress-Length (SL) linguistic system. SL builds words from syllables,
# where each syllable has two vocalic features: stress and (vowel) length.
# Each output must have exactly one stress-bearing syllable.
module SL
  # Contains the core elements of the SL (stress-length) linguistic system.
  # It defines the constraints of the system, and provides key procedures:
  # * #gen - generating the candidates for an input.
  # * #input_from_morphword - constructs the phonological input
  #   corresponding to a morphological word.
  # * #parse_output - parses a phonological output into a full word
  #   (structural description).
  #
  # ===Non-injected Class Dependencies
  # * The classes within the module SL.
  # * Constraint
  # * InputBuilder
  # * ODL::ElementGenerator
  # * ODL::UnderlyingFormGenerator
  # * ODL::LexicalEntryGenerator
  # * ODL::CompetitionGenerator
  # * ODL::StressLengthDataGenerator
  class System
    # Indicates that a constraint is a markedness constraint.
    MARK = Constraint::MARK

    # Indicates that a constraint is a faithfulness constraint.
    FAITH = Constraint::FAITH

    # The list of constraints. The list is frozen, as are the constraints.
    attr_reader :constraints

    # The class of objects that are in correspondence relations, e.g.,
    # the syllable class.
    attr_reader :corr_element_class

    # Returns a new SL::System object.
    # :call-seq:
    #   new -> system
    def initialize
      @corr_element_class = Syllable
      @gen = gen_instance
      @constraints = constraint_list
      @constraints.each(&:freeze) # freeze the constraints
      @constraints.freeze # freeze the constraint list
      @input_builder = InputBuilder.new
      @output_parser = OutputParser.new(self)
      @data_generator = initialize_data_generation
    end

    # Accepts parameters of a morph_word and a lexicon. It builds an
    # input form by concatenating the syllables of the underlying forms
    # of each of the morphemes in the morph_word, in order. It also
    # constructs the correspondence relation between the underlying forms
    # of the lexicon and the input, with an entry for each corresponding
    # pair of underlying/input syllables.
    # :call-seq:
    #   input_from_morphword(mwd, lexicon) -> input
    def input_from_morphword(mwd, lexicon)
      @input_builder.input_from_morphword(mwd, lexicon)
    end

    # Takes an input, generates all candidate words for that input, and
    # returns the candidates in an array. All candidates share the same
    # input object. The outputs may also share some of their syllable
    # objects.
    # :call-seq:
    #   gen(input) -> arr
    def gen(input)
      @gen.run(input)
    end

    # Constructs a full structural description for the given output using
    # the given lexicon. The constructed input will stand in
    # 1-to-1 IO correspondence with the output; an exception is thrown if
    # the number of syllables in the lexical entry of each morpheme doesn't
    # match the number of syllables for that morpheme in the output.
    # :call-seq:
    #   parse_output(output, lexicon) -> word
    def parse_output(output, lexicon)
      @output_parser.parse_output(output, lexicon)
    end

    # Returns a list of competitions for all inputs consisting
    # of one root and one suffix, where all of the roots have one
    # syllable, and all of the suffixes have 1 syllable.
    # :call-seq:
    #   generate_competitions_1r1s -> arr
    def generate_competitions_1r1s
      @data_generator.generate_competitions_1r1s
    end

    # Returns a new instance of SL::Gen, the GEN function for system SL.
    # It is initialized with a reference to the current system object.
    def gen_instance
      Gen.new(self)
    end
    private :gen_instance

    # Constructs and connects together the generators for
    # basic representational elements. Returns a data generator,
    # which is used to generate sets of competitions.
    def initialize_data_generation
      element_generator = ODL::ElementGenerator.new(corr_element_class)
      uf_generator = ODL::UnderlyingFormGenerator.new(element_generator)
      lexentry_generator = ODL::LexicalEntryGenerator.new(uf_generator)
      comp_generator = ODL::CompetitionGenerator.new(self)
      ODL::StressLengthDataGenerator.new(lexentry_generator, comp_generator)
    end
    private :initialize_data_generation

    # Returns an array of the constraints.
    def constraint_list
      list = []
      list << Constraint.new(NoLong.new)
      list << Constraint.new(Wsp.new)
      list << Constraint.new(MainLeft.new)
      list << Constraint.new(MainRight.new)
      list << Constraint.new(IdentStress.new)
      list << Constraint.new(IdentLength.new)
      list
    end
    private :constraint_list
  end
end
