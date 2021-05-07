# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'singleton'
require 'pas/syllable'
require 'constraint'
require 'input'
require 'ui_correspondence'
require 'word'
require 'underlying'
require 'lexical_entry'
require 'odl/element_generator'
require 'odl/underlying_form_generator'
require 'odl/lexical_entry_generator'
require 'odl/competition_generator'
require 'odl/stress_length_data_generator'

# Module PAS contains the linguistic system elements defining the
# Pitch Accent Stress (PAS) linguistic system. PAS builds words from syllables,
# where each syllable has two vocalic features: stress and (vowel) length.
# Each output has at most one stress-bearing syllable (stressless outputs
# are possible).
module PAS
  # Contains the core elements of the PAS (pitch accent stress) linguistic system.
  # It defines the constraints of the system, provides the #gen(_input_) method
  # generating the candidates for _input_, provides a method for
  # constructing the phonological input corresponding to a morphological
  # word with respect to a given grammar, and provides a method for parsing
  # a phonological output for a morphological word into a full structural
  # description with respect to a given grammar.
  #
  # This is a singleton class.
  #
  # ===Non-injected Class Dependencies
  # * PAS::Syllable
  # * Constraint
  # * Input
  # * UICorrespondence
  # * Word
  class System
    include Singleton

    # Create local references to the constraint type constants.
    # This is strictly for convenience, so that the "Constraint::"
    # prefix doesn't have to appear in the constraint definitions below.
    # Note: done this way because constants cannot be aliased.

    # Indicates that a constraint is a markedness constraint.
    MARK = Constraint::MARK
    # Indicates that a constraint is a faithfulness constraint.
    FAITH = Constraint::FAITH

    # The list of constraints. The list is frozen, as are the constraints.
    attr_reader :constraints

    # Returns the markedness constraint NoLong.
    attr_reader :nolong

    # Returns the markedness constraint WSP.
    attr_reader :wsp

    # Returns the markedness constraint ML.
    attr_reader :ml

    # Returns the markedness constraint MR.
    attr_reader :mr

    # Returns the faithfulness constraint IDStress.
    attr_reader :idstress

    # Returns the faithfulness constraint IDLength.
    attr_reader :idlength

    # Returns the markedness constraint CULM
    attr_reader :culm

    # Creates and freezes the constraints and the constraint list.
    def initialize
      initialize_constraints
      @constraints = constraint_list # private method creating the list
      @constraints.each(&:freeze) # freeze the constraints
      @constraints.freeze # freeze the constraint list
      @data_generator = initialize_data_generation
    end

    # Accepts parameters of a morph_word and a lexicon. It builds an
    # input form by concatenating the syllables of the underlying forms
    # of each of the morphemes in the morph_word, in order. It also
    # constructs the correspondence relation between the underlying forms
    # of the lexicon and the input, with an entry for each corresponding
    # pair of underlying/input syllables.
    def input_from_morphword(mwd, lexicon)
      input = Input.new
      input.morphword = mwd
      mwd.each do |m| # for each morpheme in the morph_word, in order
        lex_entry = lexicon.find { |entry| entry.morpheme == m }
        raise "Morpheme #{m.label} has no lexical entry." if lex_entry.nil?

        uf = lex_entry.uf
        msg1 = "The lexical entry for morpheme #{m.label}"
        msg2 = 'has no underlying form.'
        raise "#{msg1} #{msg2}" if uf.nil?

        uf.each do |syl|
          in_syl = syl.dup
          # add a duplicate of the underlying syllable to input.
          input.push(in_syl)
          # create a correspondence between underlying and input syllables.
          input.ui_corr.add_corr(syl, in_syl)
        end
      end
      input
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
        # copy the partial candidate lists to old_*, and reset the lists to empty.
        old_no_stress_yet = no_stress_yet
        old_main_stress_assigned = main_stress_assigned
        no_stress_yet = []
        main_stress_assigned = []
        # iterate over old_no_stress_yet, for each member create a new candidate
        # for each of the ways of adding the next syllable.
        old_no_stress_yet.each do |w|
          no_stress_yet << extend_word_output(w, isyl) { |s| s.set_unstressed.set_short }
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_main_stress.set_short }
          no_stress_yet << extend_word_output(w, isyl) { |s| s.set_unstressed.set_long }
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_main_stress.set_long }
        end
        # iterate over old_main_stress_assigned, for each member create
        # a new candidate for each of the ways of adding the next syllable.
        old_main_stress_assigned.each do |w|
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_unstressed.set_short }
          main_stress_assigned << extend_word_output(w, isyl) { |s| s.set_unstressed.set_long }
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

    # Constructs a full structural description for the given output using the
    # given lexicon. The constructed input will stand in
    # 1-to-1 IO correspondence with the output; an exception is thrown if
    # the number of syllables in the lexical entry of each morpheme doesn't
    # match the number of syllables for that morpheme in the output.
    def parse_output(output, lexicon)
      mw = output.morphword
      # If any morphemes aren't currently in the lexicon, create new entries, with
      # the same number of syllables as in the output, and all features unset.
      mw.each do |m|
        next if lexicon.any? { |entry| entry.morpheme == m }

        under = Underlying.new
        # create a new UF syllable for each syllable of m in the output
        syls_of_m = output.find_all { |syl| syl.morpheme == m }
        syls_of_m.each { |_x| under << Syllable.new.set_morpheme(m) }
        lexicon << LexicalEntry.new(m, under)
      end
      # Construct the input form
      input = input_from_morphword(mw, lexicon)
      word = Word.new(self, input, output)
      # Sanity check: 1-to-1 corresp. requires same sizes.
      msg_s = "Input size #{input.size} != output size #{output.size}."
      raise "system.parse_output: #{msg_s}" if input.size != output.size

      # create 1-to-1 IO correspondence
      # Iterate over successive input and output syllables, adding each
      # pair to the word's correspondence relation.
      input.each_with_index do |in_syl, idx|
        out_syl = output[idx]
        word.add_to_io_corr(in_syl, out_syl)
        next unless in_syl.morpheme != out_syl.morpheme

        msg1 = "Input syllable morph #{in_syl.morpheme.label} != "
        msg2 = "output syllable morph #{out_syl.morpheme.label}"
        raise "#{msg1}#{msg2}"
      end
      word.eval # compute the number of violations of each constraint
      word
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
    def generate_competitions_1r1s
      @data_generator.generate_competitions_1r1s
    end

    private

    # This defines the constraints, and stores each in the appropriate
    # class variable.
    def initialize_constraints
      @nolong = Constraint.new('NoLong', MARK) do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? then sum + 1 else sum end
        end
      end
      @wsp = Constraint.new('WSP', MARK) do |cand|
        cand.output.inject(0) do |sum, syl|
          if syl.long? && syl.unstressed? then sum + 1 else sum end
        end
      end
      @ml = Constraint.new('ML', MARK) do |cand|
        viol_count = 0
        # only apply when there's a main stress in the cand
        main_stress_found = cand.output.main_stress?
        if main_stress_found
          cand.output.each do |syl|
            break if syl.main_stress?

            viol_count += 1
          end
        end
        viol_count
      end
      @mr = Constraint.new('MR', MARK) do |cand|
        viol_count = 0
        stress_found = false
        cand.output.each do |syl|
          viol_count += 1 if stress_found
          stress_found = true if syl.main_stress?
        end
        viol_count
      end
      @idstress = Constraint.new('IDStress', FAITH) do |cand|
        viol_count = 0
        cand.input.each do |in_syl|
          unless in_syl.stress_unset?
            out_syl = cand.io_out_corr(in_syl)
            viol_count += 1 if in_syl.main_stress? != out_syl.main_stress?
          end
        end
        viol_count
      end
      @idlength = Constraint.new('IDLength', FAITH) do |cand|
        viol_count = 0
        cand.input.each do |in_syl|
          unless in_syl.length_unset?
            out_syl = cand.io_out_corr(in_syl)
            viol_count += 1 if in_syl.long? != out_syl.long?
          end
        end
        viol_count
      end
      # Gives a single violation to stress-less outputs.
      @culm = Constraint.new('Culm', MARK) do |cand|
        not_violated = cand.output.main_stress?
        if not_violated
          0
        else
          1
        end
      end
    end

    # Define the constraint list.
    def constraint_list
      list = []
      list << @nolong
      list << @wsp
      list << @ml
      list << @mr
      list << @idstress
      list << @idlength
      list << @culm
      list
    end

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
