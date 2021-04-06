# frozen_string_literal: true

# Author: Bruce Tesar

require 'loser_selector_from_gen'
require 'otlearn/erc_learning'
require 'otlearn/grammar_test'
require 'otlearn/single_form_learning'

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
  #   phonotatic learning.
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

    # Returns a new SingleFormLearningFactory object.
    # :call-seq:
    #   SingleFormLearningFactory.new -> factory
    def initialize; end

    # Returns an OTLearn::SingleFormLearning object matching
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

    # Checks that all required components are defined before
    # building a single form learner.
    # Returns true if no errors occurred.
    def check_factory_settings
      msg1 = 'SingleFormLearningFactory#build:'
      # If no linguistic system has been specified, raise an error.
      raise "#{msg1} no system specified." if system.nil?

      # If no learning comparer has been specified, raise an error.
      msg2 = 'no learning comparer specified.'
      raise "#{msg1} #{msg2}" if learning_comparer.nil?

      # If no testing comparer has been specified, raise an error.
      msg2 = 'no testing comparer specified.'
      raise "#{msg1} #{msg2}" if testing_comparer.nil?

      true # return value if no errors raised
    end
    private :check_factory_settings

    def create_para_erc_learner(selector)
      para_erc_learner = OTLearn::ParadigmErcLearning.new
      para_erc_learner.erc_learner = create_erc_learner(selector)
      para_erc_learner
    end
    private :create_para_erc_learner

    def create_loser_selector(comparer)
      LoserSelectorFromGen.new(system, comparer)
    end
    private :create_loser_selector

    def create_erc_learner(selector)
      erc_learner = OTLearn::ErcLearning.new
      erc_learner.loser_selector = selector
      erc_learner
    end
    private :create_erc_learner

    def create_grammar_tester(selector)
      tester = OTLearn::GrammarTest.new
      tester.loser_selector = selector
      tester
    end
    private :create_grammar_tester
  end
end
