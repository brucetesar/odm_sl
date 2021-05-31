# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/consistency_checker'
require 'feature_value_pair'
require 'word_search'
require 'otlearn/learning_exceptions'
require 'otlearn/inductive_feature_value_finder'
require 'otlearn/paradigm_erc_learning'
require 'otlearn/fsf_substep'

module OTLearn
  # FewestSetFeatures searches for a single unset feature that, when set to
  # its surface realization for a word, allows that word to pass
  # word evaluation.
  # This class would typically be invoked when neither single form learning nor
  # contrast pairs are able to make further progress, yet learning is
  # not yet complete, suggesting that a paradigmatic subset relation is present.
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
  #
  # Future research will be needed to determine if
  # the learner should evaluate each failed winner, and then select
  # the failed winner requiring the minimal number of set features.
  class FewestSetFeatures
    # The learner for ERC info from newly set features.
    attr_accessor :para_erc_learner

    # Returns a new FSF object.
    # :call-seq:
    #   FewestSetFeatures.new -> fsf_learner
    #--
    # * fv_pair_class - the class of object used to represent
    #   feature-value pairs. Used for testing (dependency injection).
    # * word_search: search object containing #find_unset_features_in_words.
    def initialize(consistency_checker: nil, fv_pair_class: nil,
                   word_search: nil, feature_value_finder: nil)
      @consistency_checker = consistency_checker || ConsistencyChecker.new
      @fv_pair_class = fv_pair_class || FeatureValuePair
      @word_search = word_search || WordSearch.new
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
    # If a unique single feature is identified among the unset features of
    # a failed winner that rescues that winner, then that feature is set in
    # the grammar. The learner pursues non-phonotactic ranking information
    # for the newly set feature.
    #
    # Returns an FsfSubstep object.
    #
    # If more than one individual unset feature is found that will succeed
    # for the selected failed winner, then a LearnEx exception is raised,
    # containing a reference to the list of (more than one) successful
    # features.
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
      # Choose a solution
      winner, soln_features = choose_solution(success_instances)
      return FsfSubstep.new([], nil) if soln_features.empty?

      # Adopt the solution
      newly_set_features = adopt_solution(soln_features, grammar, output_list)
      FsfSubstep.new(newly_set_features, winner)
    end

    def choose_solution(instances)
      return [nil, []] if instances.empty?

      chosen = instances.first
      [chosen.winner, chosen.values]
    end
    private :choose_solution

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
    end
    private :adopt_solution
  end
end
