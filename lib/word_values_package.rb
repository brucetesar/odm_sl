# frozen_string_literal: true

# Author: Bruce Tesar

# Packages together a word with a list of feature-value pairs
# for selected features of the word.
#
# This class was constructed for use in the Fewest Set Features algorithm
# in inductive learning.
class WordValuesPackage
  # The word containing the features.
  attr_reader :word

  # The list of feature-value pairs.
  attr_reader :values

  # Returns a new word+values package object.
  # :call-seq:
  #   new(word, values) -> package
  def initialize(word, values)
    @word = word
    @values = values
  end
end
