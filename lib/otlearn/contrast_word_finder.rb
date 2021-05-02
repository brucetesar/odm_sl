# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/alt_env_finder'

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
    # === Parameters
    # * grammar - the grammar containing the lexicon that indicates
    #   which features are unset.
    # :call-seq:
    #   new(grammar) -> finder
    #--
    # Named parameters contrast_matcher and alt_env_finder are dependency
    # injections used in testing.
    def initialize(grammar, contrast_matcher: nil, alt_env_finder: nil)
      @grammar = grammar
      @cw_matcher = contrast_matcher
      @alt_env_finder = alt_env_finder || AltEnvFinder.new(@grammar)
    end

    # Returns an array of words in _others_ that form valid contrast pairs
    # with _ref_word_.
    # :call-seq:
    #   contrast_words(ref_word, others) -> array
    def contrast_words(ref_word, others)
      ref_mw = ref_word.morphword
      cword_list = []
      ref_mw.each do |m|
        # find words that morphologically match in all but the target morpheme
        # TODO: have cw_matcher return the morpheme constrasting with m, or
        # nil if there is no match. Then, check if at least one of m and
        # its contrasting morpheme have an unset feature. If not, don't add
        # the word to mw_matches (nothing to set).
        mw_matches =
          others.find_all { |o| @cw_matcher.match?(ref_mw, m, o.morphword) }
        # find words alternating in an unset feature relative to ref_word
        alternating_words = @alt_env_finder.find(ref_word, m, mw_matches)
        alternating_words.each { |w| cword_list << w }
      end
      cword_list
    end
  end
end
