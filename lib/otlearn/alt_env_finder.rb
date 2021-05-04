# frozen_string_literal: true

# Author: Bruce Tesar

require 'word_search'

module OTLearn
  # Finds words that alternate on an unset feature with respect to
  # a reference word. This is used in constructing contrast pairs.
  # == Illustration
  # * grammar: r1 = /?,-/ s1 = /?,-/ s3 = /?,-/
  # * ref_word: r1s1
  # * others: [r1s3, r2s1, r2s3]
  # * contrast morpheme: s1
  # * r1s1 output: [+,-,-,-]  r1s3 output: [-,-,+,-]
  # r1 is the environment morpheme, and its first feature is unset.
  # That feature surfaces as + in r1s1 and as - in r1s3, so it is
  # an alternating unset environment feature. Therefore, the word
  # r1s3 provides an alternating unset feature environment relative
  # to r1s1, and qualifies as a contrast word. In other words, r1s1
  # and r1s3 constitute a valid contrast pair.
  #   finder = AltEnvFinder.new
  #   finder.find(r1s1, s1, [r1s3, r2s1, r2s3], grammar) # => [r1s3]
  class AltEnvFinder
    # Returns a new alternating environment feature word finder object.
    # :call-seq:
    #   new() -> finder
    #--
    # Named parameter word_search is a dependency injection used for
    # testing.
    def initialize(word_search: nil)
      @word_search = word_search || WordSearch.new
    end

    # Given reference word _ref_word_ and contrasting morpheme _morph_,
    # _others_ is expected to contain only words that differ with
    # _ref_word_ on _morph_, with the rest of the phonological environment
    # identical. Returns an array of words in _other_ that alternate on
    # the surface with _ref_word_ with respect to an unset feature of the
    # environment morphemes.
    # :call-seq:
    #   find(ref_word, morph, others, grammar) -> array
    def find(ref_word, morph, others, grammar)
      # The environment morphemes are all but the contrast morpheme.
      env_morphs = ref_word.morphword.reject { |m| m == morph }
      # find unset features of failed winner in the environment morphemes.
      unset_features =
        @word_search.find_unset_features(env_morphs, grammar)
      return [] if unset_features.empty?

      alternating_environment_words(ref_word, unset_features, others)
    end

    # Returns a list of words in _others_ that have a feature in
    # _unset_features_ that differs on the surface from _ref_word_.
    def alternating_environment_words(ref_word, unset_features, others)
      word_list = []
      others.each do |other|
        # Return the first feature it finds, because one alternating
        # unset feature is sufficient to qualify as a contrast word.
        alt_feature = unset_features.find do |feat_inst|
          @word_search.conflicting_output_values?(feat_inst,
                                                  [ref_word, other])
        end
        # if ref_word and other alternate on an unset feature
        # add other to the word list
        word_list << other unless alt_feature.nil?
      end
      word_list
    end
    private :alternating_environment_words
  end
end
