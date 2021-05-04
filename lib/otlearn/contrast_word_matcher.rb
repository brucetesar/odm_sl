# frozen_string_literal: true

# Author: Bruce Tesar

module OTLearn
  # Matches two words, a reference word and an other word,
  # morpheme-by-morpheme in linear order. If they different in the
  # target morpheme, but have the same morpheme in every other position,
  # then the words properly match. See documentation for the method #match().
  class ContrastWordMatcher
    # Returns a new contrast word matcher object.
    # :call-seq:
    #   new() -> matcher
    def initialize; end

    # Tries to match the morphwords _ref_mw_ and _other_mw_. The other
    # morphwword qualifies as a contrast word with respect to _morph_
    # if all of the following criteria are met:
    # * _ref_mw_ and _other_mw_ have the same number of morphemes.
    # * the target morpheme _morph_ is a morpheme of _ref_mw_.
    # * the morpheme in _other_mw_ corresponding to _morph_ in _ref_mw_
    #   is not the same as _morph_ (contrast for target morpheme).
    # * every other morpheme of _ref_mw_ is the same as its corresponding
    #   morpheme in _other_mw_ (identity of the environment morphemes).
    # If _other_mw_ qualifies as a contrast word, then the morpheme
    # of _other_mw_ corresponding to _morph_ is returned. Otherwise,
    # nil is returned.
    # Raises a RuntimeError if the target morpheme _morph_ occurs more
    # than once in _ref_mw_.
    # :call-seq:
    #   match(ref_mw, morph, other_mw) -> morpheme or nil
    def match(ref_mw, morph, other_mw)
      return nil unless edge_conditions_met?(ref_mw, morph, other_mw)

      contrast_morph = nil
      # iterate through the words morpheme by morpheme
      ref_mw.each_with_index do |_obj, idx|
        # boolean: are the corresponding morphemes not the same?
        morph_mismatch = ref_mw[idx] != other_mw[idx]
        # boolean: is the current ref word morpheme also the target?
        target_match = ref_mw[idx] == morph
        contrast_morph = other_mw[idx] if target_match && morph_mismatch
        return nil if !target_match && morph_mismatch
      end
      contrast_morph
    end

    # Checks edge conditions. Returns true if they are all met. Otherwise,
    # either returns nil or raises a RuntimeError.
    def edge_conditions_met?(ref_mw, morph, other_mw)
      # words with differing numbers of morphemes cannot match
      return nil if ref_mw.size != other_mw.size

      # Cannot have the target morph appear multiple times
      msg = 'ContrastWordMatcher#match: target word cannot appear multiple times'
      raise msg if ref_mw.find_all { |m| m == morph }.size > 1

      true
    end
    private :edge_conditions_met?
  end
end
