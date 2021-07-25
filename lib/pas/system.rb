# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'pas/syllable'
require 'constraint'
require 'sl/no_long'
require 'sl/wsp'
require 'sl/main_left'
require 'sl/main_right'
require 'sl/ident_stress'
require 'sl/ident_length'
require 'pas/culm'
require 'input_builder'
require 'sl/output_parser'
require 'word'
require 'odl/element_generator'
require 'odl/underlying_form_generator'
require 'odl/lexical_entry_generator'
require 'odl/competition_generator'
require 'odl/stress_length_data_generator'

# Module PAS contains the linguistic system elements defining the
# Pitch Accent Stress (PAS) linguistic system. PAS builds words from
# syllables, where each syllable has two vocalic features: stress and
# (vowel) length. Each output has at most one stress-bearing syllable
# (stressless outputs are possible).
module PAS
  # Contains the core elements of the PAS (pitch accent stress) linguistic
  # system. It defines the constraints of the system, and provides key
  # procedures:
  # * #gen - generating the candidates for an input.
  # * #input_from_morphword - constructs the phonological input
  #   corresponding to a morphological word.
  # * #parse_output - parses a phonological output into a full word
  #   (structural description).
  #
  # ===Non-injected Class Dependencies
  # * The classes within the module PAS.
  # * Constraint
  # * SL::NoLong
  # * SL::Wsp
  # * SL::MainLeft
  # * SL::MainRight
  # * SL::IdentStress
  # * SL::IdentLength
  # * InputBuilder
  # * SL::OutputParser
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

    # Returns a new PAS::System object.
    # :call-seq:
    #   new -> system
    def initialize
      @corr_element_class = Syllable
      @constraints = constraint_list # private method creating the list
      @constraints.each(&:freeze) # freeze the constraints
      @constraints.freeze # freeze the constraint list
      @input_builder = InputBuilder.new
      @output_parser = SL::OutputParser.new(self)
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

    # gen takes an input, generates all candidate words for that input, and
    # returns the candidates in an array. All candidates share the same input
    # object. The outputs may also share some of their syllable objects.
    def gen(input)
      start_rep = Word.new(self, input) # full input, but empty output, io_corr
      start_rep.output.morphword = input.morphword
      # create two lists of partial candidates, distinguished by whether or
      # not they contain a syllable with main stress.
      no_stress_yet = [start_rep]
      main_stress_assigned = []

      # for each input segment, add it to the output in all possible ways,
      # creating new partial candidates
      input.each do |isyl|
        # copy the partial candidate lists to old_*, reset the lists to empty.
        old_no_stress_yet = no_stress_yet
        old_main_stress_assigned = main_stress_assigned
        no_stress_yet = []
        main_stress_assigned = []
        # iterate over old_no_stress_yet, for each member create a new candidate
        # for each of the ways of adding the next syllable.
        old_no_stress_yet.each do |w|
          no_stress_yet <<
            extend_word_output(w, isyl) { |s| s.set_unstressed.set_short }
          main_stress_assigned <<
            extend_word_output(w, isyl) { |s| s.set_main_stress.set_short }
          no_stress_yet <<
            extend_word_output(w, isyl) { |s| s.set_unstressed.set_long }
          main_stress_assigned <<
            extend_word_output(w, isyl) { |s| s.set_main_stress.set_long }
        end
        # iterate over old_main_stress_assigned, for each member create
        # a new candidate for each of the ways of adding the next syllable.
        old_main_stress_assigned.each do |w|
          main_stress_assigned <<
            extend_word_output(w, isyl) { |s| s.set_unstressed.set_short }
          main_stress_assigned <<
            extend_word_output(w, isyl) { |s| s.set_unstressed.set_long }
        end
      end

      # Put actual candidates into an array, calling eval on each to set
      # the constraint violations.
      candidates = []
      main_stress_assigned.each do |c|
        c.eval
        candidates.push(c)
      end
      # also evaluate the candidates without main stress
      no_stress_yet.each do |c|
        c.eval
        candidates.push(c)
      end
      candidates
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

    # Constructs and connects together the generators for
    # basic representational elements. Returns a data generator,
    # which is used to generate sets of competitions.
    def initialize_data_generation
      element_generator = ODL::ElementGenerator.new(Syllable)
      uf_generator = ODL::UnderlyingFormGenerator.new(element_generator)
      lexentry_generator = ODL::LexicalEntryGenerator.new(uf_generator)
      comp_generator = ODL::CompetitionGenerator.new(self)
      ODL::StressLengthDataGenerator.new(lexentry_generator, comp_generator)
    end
    private :initialize_data_generation

    # Returns a list of competitions for all inputs consisting
    # of one root and one suffix, where all of the roots have one
    # syllable, and all of the suffixes have 1 syllable.
    # :call-seq:
    #   generate_competitions_1r1s -> arr
    def generate_competitions_1r1s
      @data_generator.generate_competitions_1r1s
    end

    # Returns an array of the constraints. The content of six of the
    # seven constraints comes from the SL linguistic system.
    def constraint_list
      list = []
      list << Constraint.new(SL::NoLong.new)
      list << Constraint.new(SL::Wsp.new)
      list << Constraint.new(SL::MainLeft.new)
      list << Constraint.new(SL::MainRight.new)
      list << Constraint.new(SL::IdentStress.new)
      list << Constraint.new(SL::IdentLength.new)
      list << Constraint.new(PAS::Culm.new)
      list
    end
    private :constraint_list

    # Takes a word partial description (full input, partial output), along with
    # a reference to the next input syllable to have a correspondent added
    # to the output. A copy of the word, containing the new output syllable
    # as an output correspondent to the input syllable, is returned.
    #
    # The new output syllable is formed by duplicating
    # the input syllable (to copy morpheme info, etc.), and then the output
    # syllable is passed to the block parameter, which sets the feature values
    # for the new output syllable. The new output syllable is added to the end
    # of the output, and a new IO correspondence pair is added.
    def extend_word_output(word, in_syl)
      new_w = word.dup_for_gen
      out_syl = yield(in_syl.dup) # block sets features of new output syllable.
      new_w.output << out_syl
      new_w.add_to_io_corr(in_syl, out_syl)
      new_w
    end
  end
end
