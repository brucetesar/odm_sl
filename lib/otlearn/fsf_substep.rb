# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'

module OTLearn
  # Represents the results of a Fewest Set Features substep of
  # induction learning.
  class FsfSubstep
    # The subtype of the substep, OTLearn::FEWEST_SET_FEATURES
    attr_reader :subtype

    # The list of features newly set by FSF.
    # NOTE: at present, OTLearn::FewestSetFeatures will set at most one
    # feature, but may be extended to return a minimal set of features
    # in the future, so this attribute is a list.
    attr_reader :newly_set_features

    # The failed winner that was used with FSF.
    attr_reader :failed_winner

    # Array of all successful winner/feature instances
    attr_reader :success_instances

    # Returns a new substep object for an Fewest Set Features substep.
    # :call-seq:
    #   #FsfSubstep.new(newly_set_features, failed_winner, success_instances)
    #   -> substep
    def initialize(newly_set_features, failed_winner, success_instances)
      @subtype = FEWEST_SET_FEATURES
      @newly_set_features = newly_set_features
      @failed_winner = failed_winner
      @success_instances = success_instances
    end

    # Returns true if FSF set at least one feature, false otherwise.
    def changed?
      !@newly_set_features.empty?
    end
  end
end
