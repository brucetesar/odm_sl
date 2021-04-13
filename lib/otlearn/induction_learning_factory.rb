# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/fewest_set_features'
require 'otlearn/max_mismatch_ranking'
require 'otlearn/induction_learning'
require 'otlearn/factory_learn_test_mixin'

module OTLearn
  # A factory class for constructing induction learner objects
  # using required components. The required components must be
  # provided via attribute assignment after the initial object
  # has been constructed.
  #
  # Both MMR and FSF, the two major components of induction learning,
  # operate over select winners that failing in grammar testing.
  # Because those winners are failing when using the testing comparer,
  # MMR and FSF both use the testing comparer, to avoid the problem of
  # having a winner fail in grammar testing, but not fail for induction
  # learning due to use of a different comparer.
  #
  # === Required Components
  # * system - a linguistic system object.
  # * learning_comparer - the comparer (of candidates) used in loser
  #   selection for paradigmatic learning generally. NOTE: this is
  #   currently not used with induction learning, but is included
  #   here to maintain interface consistency with other major
  #   learning components.
  # * testing_comparer - the comparer (of candidates) used in loser
  #   selection during grammar testing at the end of induction learning.
  #   ALSO used for loser selection with MMR and FSF.
  # === Build Outline
  # The factory takes the components provided via the attributes
  # and builds the intermediate components needed by
  # OTLearn::InductionLearning objects.
  # * A testing loser selector, class LoserSelectorFromGen,
  #   is created with _system_ and _testing_comparer_.
  # * A paradigm ERC learner, class OTLearn::ParadigmErcLearning,
  #   is created with the testing loser selector.
  # * An ERC learner, class OTLearn::ErcLearning,
  #   is created with the testing loser selector.
  # * A grammar tester, class OTLearn::GrammarTest, is created with
  #   the testing loser selector.
  # * An FSF learner, class OTLearn::FewestSetFeatures, is created with
  #   the paradign erc learner.
  # * An MMR learner, class OTLearn::MaxMismatchRanking, is created with
  #   the erc learner.
  # * Finally, an OTLearn::InductionLearning object is created with
  #   the FSF learner, the MMR learner, and the grammar tester.
  class InductionLearningFactory
    # The linguistic system.
    attr_accessor :system

    # The comparer for learning. Currently included for interface
    # consistency only.
    attr_accessor :learning_comparer

    # The comparer for testing, as well as for MMR and FSF.
    attr_accessor :testing_comparer

    # Provides methods for creation of common components.
    include OTLearn::FactoryLearnTestMixin

    # Returns a new InductionLearningFactory object.
    # :call-seq:
    #   InductionLearningFactory.new -> factory
    def initialize; end

    # Returns an OTLearn::InductionLearning object matching
    # the factory-specified settings.
    #
    # Raises a RuntimeError if any of the required components
    # have not been provided.
    def build
      check_factory_settings
      test_selector = create_loser_selector(testing_comparer)
      fsf_learner, mmr_learner = create_learning_components(test_selector)
      # Assign the induction learning components
      in_learner = InductionLearning.new
      in_learner.fsf_learner = fsf_learner
      in_learner.mmr_learner = mmr_learner
      in_learner.grammar_tester = create_grammar_tester(test_selector)
      in_learner
    end

    # Creates the Fewest Set Features learner and the Max Mismatch Ranking
    # learner.
    def create_learning_components(selector)
      fsf_learner = FewestSetFeatures.new
      fsf_learner.para_erc_learner = create_para_erc_learner(selector)
      mmr_learner = MaxMismatchRanking.new
      mmr_learner.erc_learner = create_erc_learner(selector)
      [fsf_learner, mmr_learner]
    end
    private :create_learning_components
  end
end
