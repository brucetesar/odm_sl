# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  class ContrastWordFinder
    def initialize(grammar, contrast_matcher: nil,
                   word_search: WordSearch.new)
      @grammar = grammar
      @cw_matcher = contrast_matcher
      @word_search = word_search
    end

    # Returns an array of words in _others_ that form valid contrast pairs
    # with _ref_word_.
    def contrast_words(ref_word, others)
      ref_mw = ref_word.morphword
      cword_list = []
      ref_mw.each do |m|
        # find words that morphologically match in all but the target morpheme
        mw_matches =
          others.find_all { |o| @cw_matcher.match?(ref_mw, m, o.morphword) }
        # find words alternating in an unset feature relative to ref_word
        alternating_words = words_with_alt_unset_feat(ref_word, m, mw_matches)
        alternating_words.each { |w| cword_list << w }
      end
      cword_list
    end

    def words_with_alt_unset_feat(ref_word, morph, others)
      word_list = []
      env_morphs = ref_word.morphword - [morph]
      # find unset features of failed winner outside of target morpheme
      unset_features =
        @word_search.find_unset_features(env_morphs, @grammar)
      return [] if unset_features.empty?

      others.each do |other|
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
  end
end
