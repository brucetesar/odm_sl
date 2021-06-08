# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # Represents the results of a Fewest Set Features substep of
  # induction learning.
  class FsfSubstep
    # The subtype of the substep, OTLearn::FEWEST_SET_FEATURES
    attr_reader :subtype

    # The chosen word/values package, with the newly set features.
    attr_reader :chosen_package

    # List of all the consistent word/values packages.
    attr_reader :consistent_packages

    # Returns a new substep object for a Fewest Set Features substep.
    # === Parameters
    # * chosen_package - a word/features package representing the features
    #   that were actually set, rendering the word contained in
    #   the package mismatch-consistent.
    # * consistent_packages - a list of all of the word/features packages
    #   that are capable of rendering their contained word
    #   mismatch-consistent.
    # :call-seq:
    #   new(chosen_package, consistent_packages) -> substep
    def initialize(chosen_package, consistent_packages)
      @subtype = FEWEST_SET_FEATURES
      @chosen_package = chosen_package
      @consistent_packages = consistent_packages
    end

    # Returns true if FSF chose a consistent package, false otherwise.
    def changed?
      !@chosen_package.nil?
    end
  end
end
