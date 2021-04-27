# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # A contrast set is a collection of words to be processed together.
  # Typically, they are selected so that they jointly express contrasts
  # of the language, the prototypical example being a contrast pair.
  class ContrastSet < Array
    # Takes the Enumerable _word_list_, and stores a duplicate (.dup)
    # of each word of _word_list_ in the contrast set.
    # :call-seq:
    #   new(word_list) -> contrast_set
    def initialize(word_list)
      word_list.each { |word| self << word.dup }
    end

    # Returns a string representing the contrast set in a form appropriate
    # for use as a GraphViz label. The returned string is a concatenation
    # of the graphviz_oriented string representations (.to_gv) of each of
    # the words, separated by newline characters.
    # :call-seq:
    #   to_gv() -> string
    def to_gv
      gv_form = map { |word| word.input.to_gv }
      gv_form.join('\\n') # \\n will appear as '\n' in the .dot file.
    end
  end
end
