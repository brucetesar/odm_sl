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
  # === Required Components
  # * system - a linguistic system object.
  # * learning_comparer - the comparer (of candidates) used in
  #   loser selection during actual induction learning.
  # * testing_comparer - the comparer (of candidates) used in
  #   loser selection during grammar testing at the end of
  #   induction learning.
  # === Build Outline
  # The factory takes the components provided via the attributes
  # and builds the intermediate components needed by
  # OTLearn::InductionLearning objects.
  # * A learning loser selector, class LoserSelectorFromGen,
  #   is created with _system_ and _learning_comparer_.
  # * An paradigm ERC learner, class OTLearn::ParadigmErcLearning,
  #   is created with the learning loser selector.
  # * An ERC learner, class OTLearn::ErcLearning,
  #   is created with the learning loser selector.
  # * A testing loser selector, class LoserSelectorFromGen,
  #   is created with _system_ and _testing_comparer_.
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

    # The comparer for learning.
    attr_accessor :learning_comparer

    # The comparer for testing.
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
      learn_selector = create_loser_selector(learning_comparer)
      test_selector = create_loser_selector(testing_comparer)
      fsf_learner, mmr_learner = create_learning_components(learn_selector)
      # Assign the induction learning components
      in_learner = InductionLearning.new
      in_learner.fsf_learner = fsf_learner
      in_learner.mmr_learner = mmr_learner
      in_learner.grammar_tester = create_grammar_tester(test_selector)
      in_learner
    end

    # Creates the Fewest Set Features learner and the Max Mismatch Ranking
    # learner, both using the same loser selector.
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
