# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/alt_env_finder'
require 'otlearn/contrast_word_matcher'
require 'word_search'

module OTLearn
  # A contrast word finder identifies words, from a given list, that
  # form valid contrast pairs with a given reference word. A valid
  # contrast pair must meet several criteria:
  # * the two words differ by exactly one morpheme, the contrasting
  #   morphemes, with the rest of the morphological environment identical.
  # * at least one of the two contrasting morphemes must have an unset
  #   feature.
  # * at least one of the features of the environment morphemes must both
  #   be unset and differ in its surface realization between the two
  #   words of the contrast pair.
  class ContrastWordFinder
    # Returns a new contrast word finder object.
    # :call-seq:
    #   new() -> finder
    #--
    # Named parameters contrast_matcher, alt_env_finder and word_search
    # are dependency injections used in testing.
    def initialize(contrast_matcher: nil, alt_env_finder: nil,
                   word_search: nil)
      @contrast_matcher = contrast_matcher || ContrastWordMatcher.new
      @alt_env_finder = alt_env_finder || AltEnvFinder.new
      @word_search = word_search || WordSearch.new
    end

    # Returns an array of words in _others_ that form valid contrast pairs
    # with _ref_word_. The lexicon indicating which features are unset
    # is provided by _grammar_.
    # :call-seq:
    #   contrast_words(ref_word, others, grammar) -> array
    def contrast_words(ref_word, others, grammar)
      ref_mw = ref_word.morphword
      cword_list = []
      ref_mw.each do |m|
        # find each word that morphologically matches in all but the target
        # morpheme, paired with the contrasting morpheme of the word.
        mw_matches = find_morphword_matches(ref_mw, m, others)
        # Only keep words where one of the contrasting morphemes has an
        # unset feature.
        match_words = check_for_unset_features(m, mw_matches, grammar)
        # find words alternating in an unset feature relative to ref_word
        alternating_words =
          @alt_env_finder.find(ref_word, m, match_words, grammar)
        alternating_words.each { |w| cword_list << w }
      end
      cword_list
    end

    # Returns an array of pairs of [morpheme, word], one for each word in
    # _others_ that is a contrast word for _ref_mw_. The paired morpheme
    # is the morpheme of word that contrasts with the _morph_ of _ref_mw_.
    def find_morphword_matches(ref_mw, morph, others)
      others.each_with_object([]) do |o, memo|
        match_morph = @contrast_matcher.match(ref_mw, morph, o.morphword)
        memo << [match_morph, o] unless match_morph.nil?
      end
    end
    private :find_morphword_matches

    # Returns an array of words that have a contrast morpheme
    # corresponding to the target morpheme _morph_, such that either the
    # _morph_ or the contrast morpheme has at least one unset feature.
    #
    # The point of contrast pairs is to set at least one feature in one
    # of the contrasting morphemes, so if there are no features to set,
    # there is no point in processing the pair.
    def check_for_unset_features(morph, mw_matches, grammar)
      # if the target morpheme has an unset feature, return all of the
      # mw match words.
      return mw_matches.map { |pair| pair[1] }\
        unless @word_search.find_unset_features([morph], grammar).empty?

      # Target morph has no unset features, so check each contrast morph
      # for unset features, returning only those words with unset
      # contrast morpheme features.
      unset_matches = mw_matches.reject do |pair|
        @word_search.find_unset_features([pair[0]], grammar).empty?
      end
      unset_matches.map { |pair| pair[1] }
    end
    private :check_for_unset_features
  end
end
