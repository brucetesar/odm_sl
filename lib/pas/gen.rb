# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'word'

module PAS
  # Gen function for system PAS.
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

    def run(input)
      start_rep = Word.new(@system, input) # full input, but empty output, io_corr
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
      # Combine candidates with and without a main stress
      candidates = main_stress_assigned + no_stress_yet
      # Set the constraint violations for each candidate, return array.
      candidates.each(&:eval)
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
    private :extend_word_output
  end
end
