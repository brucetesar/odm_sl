# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/phonotactic_learning'
require 'otlearn/factory_learn_test_mixin'

module OTLearn
  # A factory class for constructing phonotactic learner objects
  # using required components. The required components must be
  # provided via attribute assignment after the initial object
  # has been constructed.
  # === Required Components
  # * system - a linguistic system object.
  # * learning_comparer - the comparer (of candidates) used in
  #   loser selection during actual phonotactic learning.
  # * testing_comparer - the comparer (of candidates) used in
  #   loser selection during grammar testing at the end of
  #   phonotatic learning.
  # === Build Outline
  # The factory takes the components provided via the attributes
  # and builds the intermediate components needed by
  # OTLearn::PhonotacticLearning objects.
  # * A learning loser selector, class LoserSelectorFromGen,
  #   is created with _system_ and _learning_comparer_.
  # * An ERC learner, class OTLearn::ErcLearning, is created with
  #   the learning loser selector.
  # * A testing loser selector, class LoserSelectorFromGen,
  #   is created with _system_ and _testing_comparer_.
  # * A grammar tester, class OTLearn::GrammarTest, is created with
  #   the testing loser selector.
  # * Finally, an OTLearn::PhonotacticLearning object is created with
  #   the ERC learner and the grammar tester.
  class PhonotacticLearningFactory
    # The linguistic system
    attr_accessor :system

    # The comparer for learning
    attr_accessor :learning_comparer

    # The comparer for testing
    attr_accessor :testing_comparer

    # Provides methods for creation of common components.
    include FactoryLearnTestMixin

    # Returns a new PhonotacticLearningFactory object.
    # :call-seq:
    #   new -> factory
    def initialize; end

    # Returns an OTLearn::PhonotacticLearning object matching
    # the factory-specified settings.
    #
    # Raises a RuntimeError if any of the required components
    # have not been provided.
    def build
      check_factory_settings
      learn_selector = create_loser_selector(learning_comparer)
      erc_learner = create_erc_learner(learn_selector)
      test_selector = create_loser_selector(testing_comparer)
      tester = create_grammar_tester(test_selector)
      ph_learner = PhonotacticLearning.new
      ph_learner.erc_learner = erc_learner
      ph_learner.grammar_tester = tester
      ph_learner
    end
  end
end
