# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # Represents the results of a Fewest Set Features substep of
  # induction learning.
  class FsfSubstep
    # The subtype of the substep, OTLearn::FEWEST_SET_FEATURES
    attr_reader :subtype

    # The list of feature/value pairs newly set by FSF.
    # NOTE: at present, OTLearn::FewestSetFeatures will set at most one
    # feature, but may be extended to return a minimal set of features
    # in the future, so this attribute is a list.
    attr_reader :newly_set_features

    # The failed winner that was used with FSF.
    attr_reader :failed_winner

    # Array of all successful winner/features instances.
    attr_reader :success_instances

    # Returns a new substep object for a Fewest Set Features substep.
    # === Parameters
    # * set_features - a set of word/feature packages, each package
    #   representing a feature/value pair that was actually set, such that
    #   the newly set features render the failed winner mismatch-consistent.
    # * success_instancs - a list of all of the word/feature package
    #   sets that are capable of rendering their contained word mismatch-
    #   consistent.
    # :call-seq:
    #   #FsfSubstep.new(set_features, success_instances)
    #   -> substep
    def initialize(set_features, success_instances)
      @subtype = FEWEST_SET_FEATURES
      if set_features.nil?
        @newly_set_features = []
        @failed_winner = nil
      else
        @newly_set_features = set_features.values
        @failed_winner = set_features.winner
      end
      @success_instances = success_instances
    end

    # Returns true if FSF set at least one feature, false otherwise.
    def changed?
      !@newly_set_features.empty?
    end
  end
end
