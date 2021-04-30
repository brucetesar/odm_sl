# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  class ContrastWordFinder
    def initialize(grammar)
      @grammar = grammar
    end

    # Returns an array of words in _others_ that form valid contrast pairs
    # with _ref_word_.
    def contrast_words(ref_word, others)
      []
    end
    # iterate over morphemes of the failed winner
    # find unset features of failed winner outside of target morpheme
    # find working list winners that differ only in the target morpheme
    # iterate over candidate winners
    # if failed_winner and candidate_winner alternate on an unset feature
    # yield the pair as a contrast pair
  end
end
