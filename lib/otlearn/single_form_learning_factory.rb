# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/single_form_learning'
require 'otlearn/factory_learn_test_mixin'

module OTLearn
  # A factory class for constructing single form learner objects
  # using required components. The required components must be
  # provided via attribute assignment after the initial object
  # has been constructed.
  # === Required Components
  # * system - a linguistic system object.
  # * learning_comparer - the comparer (of candidates) used in
  #   loser selection during actual single form learning.
  # * testing_comparer - the comparer (of candidates) used in
  #   loser selection during grammar testing at the end of
  #   single form learning.
  # === Build Outline
  # The factory takes the components provided via the attributes
  # and builds the intermediate components needed by
  # OTLearn::SingleFormLearning objects.
  # * A learning loser selector, class LoserSelectorFromGen,
  #   is created with _system_ and _learning_comparer_.
  # * An paradigm ERC learner, class OTLearn::ParadigmErcLearning,
  #   is created with the learning loser selector.
  # * A testing loser selector, class LoserSelectorFromGen,
  #   is created with _system_ and _testing_comparer_.
  # * A grammar tester, class OTLearn::GrammarTest, is created with
  #   the testing loser selector.
  # * Finally, an OTLearn::SingleFormLearning object is created with
  #   the paradigm ERC learner and the grammar tester.
  class SingleFormLearningFactory
    # The linguistic system.
    attr_accessor :system

    # The comparer for learning.
    attr_accessor :learning_comparer

    # The comparer for testing.
    attr_accessor :testing_comparer

    # Provides methods for creation of common components.
    include FactoryLearnTestMixin

    # Returns a new SingleFormLearningFactory object.
    # :call-seq:
    #   new -> factory
    def initialize; end

    # Returns a SingleFormLearning object matching
    # the factory-specified settings.
    #
    # Raises a RuntimeError if any of the required components
    # have not been provided.
    def build
      check_factory_settings
      learn_selector = create_loser_selector(learning_comparer)
      para_erc_learner = create_para_erc_learner(learn_selector)
      test_selector = create_loser_selector(testing_comparer)
      tester = create_grammar_tester(test_selector)
      sf_learner = SingleFormLearning.new
      sf_learner.para_erc_learner = para_erc_learner
      sf_learner.grammar_tester = tester
      sf_learner
    end
  end
end
