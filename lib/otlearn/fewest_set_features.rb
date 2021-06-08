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
      # Find all of the word/features packages that can render a failed
      # winner mismatch-consistent.
      consistent_packages = []
      prior_result.failed_winners.each do |failed_winner|
        consistent_packages.concat\
          @feature_value_finder.run(failed_winner, grammar, prior_result)
      end
      # If no solutions were found, return a substep indicating so.
      return FsfSubstep.new(nil, []) if consistent_packages.empty?

      # Choose a consistent package.
      chosen = choose_package(consistent_packages)
      # Set the features of the package in the lexicon of the grammar.
      adopt_feature_values(chosen.values, grammar, output_list)
      FsfSubstep.new(chosen, consistent_packages)
    end

    # Chooses, from among the consistent word/features packages, the one
    # to actually adopt.
    def choose_package(instances)
      instances.first
    end
    private :choose_package

    # Sets the features to the values specified in the feature/value pairs,
    # and checks for any new paradigmatic ranking information from the
    # newly set features. Returns nil.
    def adopt_feature_values(feature_values, grammar, output_list)
      # set each package feature.
      feature_values.each(&:set_to_alt_value)
      # Check for any new ranking information from newly set features.
      # This is done after all provided features have been set, to
      # maximize the potential for finding additional information.
      feature_values.each do |fv_pair|
        @para_erc_learner.run(fv_pair.feature_instance, grammar,
                              output_list)
      end
      nil
    end
    private :adopt_feature_values
  end
end
