# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/inductive_feature_value_finder'
require 'otlearn/paradigm_erc_learning'
require 'otlearn/fsf_substep'

module OTLearn
  # FewestSetFeatures searches for an unset feature that, when set to its
  # surface realization for a word, allows that word to pass word
  # evaluation.
  # This class would typically be invoked when neither single form learning
  # nor contrast pairs are able to make further progress, yet learning is
  # not yet complete, suggesting that a paradigmatic subset relation is
  # present.
  #
  # The name "fewest set features" refers to the idea that more features
  # need to be set to make a word successful, but setting fewer features
  # correlates with greater restrictiveness, so the learner should set the
  # minimal number of features necessary to get the word to succeed. At
  # present, the learner implements "minimal number of features" as
  # "only one feature".
  # In principle, this algorithm can be generalized to search for a minimal
  # number of features to set (as the name implies), rather than only a
  # single one. Implementation of that is waiting for the discovery of
  # a case where it is necessary.
  class FewestSetFeatures
    # The learner for ERC info from newly set features.
    attr_accessor :para_erc_learner

    # Returns a new FSF object.
    # :call-seq:
    #   FewestSetFeatures.new -> fsf_learner
    #--
    # Named parameter _feature_value_finder_ is a dependency injection used
    # for testing.
    def initialize(feature_value_finder: nil)
      @feature_value_finder = feature_value_finder ||
                              InductiveFeatureValueFinder.new
      @para_erc_learner = ParadigmErcLearning.new
    end

    # Executes the fewest set features algorithm.
    # * prior_result is the most recent result of grammar testing, and
    #   provides a list of the winners failing word evaluation.
    # * grammar is the current grammar of the learner.
    # * output_list is a list of all the winner outputs currently stored by
    #   the learner. It is used when searching for non-phonotactic ranking
    #   information when a feature has been set.
    # The learner selects a feature from among the unset features of
    # a failed winner that rescues that winner, and the selected feature is
    # set in the grammar. The learner pursues non-phonotactic ranking
    # information for the newly set feature.
    #
    # Returns an FsfSubstep object.
    # :call-seq:
    #   run(output_list, grammar, prior_result) -> substep
    def run(output_list, grammar, prior_result)
      # Find all of the feature instance sets that can render a failed
      # winner mismatch-consistent.
      success_instances = []
      prior_result.failed_winners.each do |failed_winner|
        success_instances.concat\
          @feature_value_finder.run(failed_winner, grammar, prior_result)
      end
      # If no solutions were found, return a substep indicating so.
      return FsfSubstep.new([], nil) if success_instances.empty?

      # Choose a solution
      chosen = choose_solution(success_instances)
      # Adopt the solution
      newly_set_features = adopt_solution(chosen.values, grammar, output_list)
      FsfSubstep.new(newly_set_features, chosen.winner)
    end

    # Chooses, from among the unset feature value solutions, the one
    # to actually adopt.
    def choose_solution(instances)
      instances.first
    end
    private :choose_solution

    # Sets the features to the values indicated by the solution, and check
    # for any new paradigmatic ranking information from tne newly set
    # features. Returns an array of feature instances for the newly set
    # features.
    def adopt_solution(soln_features, grammar, output_list)
      newly_set_features = []
      soln_features.each do |fv_pair|
        fv_pair.set_to_alt_value # set the feature permanently
        newly_set_features << fv_pair.feature_instance
      end
      # Check for any new ranking information based on the newly set
      # features.
      newly_set_features.each do |feat|
        @para_erc_learner.run(feat, grammar, output_list)
      end
      newly_set_features
    end
    private :adopt_solution
  end
end
