# frozen_string_literal: true

# Author: Bruce Tesar

require 'word'

module SL
  # Gen function for system SL.
  class Gen
    # Returns a new Gen instance. An input is parsed into its competition
    # of candidates by calling Gen#run(input).
    # === Parameters
    # * system - the linguistic system.
    # :call-seq:
    #   new(system) -> gen
    def initialize(system)
      @system = system
    end

    # Returns an array of all the candidates for _input_.
    # :call-seq:
    #   run(input) -> array
    def run(input)
      # full input, but empty output, io_corr
      start_rep = Word.new(@system, input)
      start_rep.output.morphword = input.morphword
      # create two lists of partial candidates, distinguished by whether or
      # not they contain a syllable with main stress.
      no_stress = [start_rep]
      main_stressed = []
      # for each input segment, add it to the output in all possible ways,
      # creating new partial candidates
      input.each do |isyl|
        # copy the lists to old_*, reset the lists to empty.
        old_no_stress = no_stress
        old_main_stressed = main_stressed
        no_stress = []
        main_stressed = []
        # iterate over old_no_stress, for each member create a new
        # candidate for each of the ways of adding the next syllable.
        extend_no_stress(isyl, old_no_stress, no_stress, main_stressed)
        # iterate over old_main_stressed, for each member create
        # a new candidate for each of the ways of adding the next syllable.
        extend_stressed(isyl, old_main_stressed, main_stressed)
      end
      # Set the constraint violations for each candidate, return array.
      main_stressed.each(&:eval)
    end

    def extend_no_stress(isyl, base_reps, no_stress, main_stressed)
      base_reps.each do |word|
        no_stress <<
          extend_word_output(word, isyl) { |s| s.set_unstressed.set_short }
        main_stressed <<
          extend_word_output(word, isyl) { |s| s.set_main_stress.set_short }
        no_stress <<
          extend_word_output(word, isyl) { |s| s.set_unstressed.set_long }
        main_stressed <<
          extend_word_output(word, isyl) { |s| s.set_main_stress.set_long }
      end
    end
    private :extend_no_stress

    def extend_stressed(isyl, base_reps, main_stressed)
      base_reps.each do |word|
        main_stressed <<
          extend_word_output(word, isyl) { |s| s.set_unstressed.set_short }
        main_stressed <<
          extend_word_output(word, isyl) { |s| s.set_unstressed.set_long }
      end
    end
    private :extend_stressed

    # Takes a word partial description (full input, partial output), along
    # with a reference to the next input syllable to have a correspondent
    # added to the output. A copy of the word, containing the new output
    # syllable as an output correspondent to the input syllable, is
    # returned.
    #
    # The new output syllable is formed by duplicating the input syllable
    # (to copy morpheme info, etc.), and then the output syllable is passed
    # to the block parameter, which sets the feature values for the new
    # output syllable. The new output syllable is added to the end of
    # the output, and a new IO correspondence pair is added.
    def extend_word_output(word, in_syl)
      new_w = word.dup_for_gen
      out_syl = yield(in_syl.dup) # block sets features of new output syl.
      new_w.output << out_syl
      new_w.add_to_io_corr(in_syl, out_syl)
      new_w
    end
    private :extend_word_output
  end
end
