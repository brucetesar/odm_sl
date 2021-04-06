# frozen_string_literal: true

# Author: Bruce Tesar

require 'loser_selector_from_gen'
require 'otlearn/erc_learning'
require 'otlearn/paradigm_erc_learning'
require 'otlearn/grammar_test'

module OTLearn
  # This mixin provides some common methods for learner factories that have
  # possibly separate comparers for learning and testing.
  # === Required
  # This mixin requires that the host class implement three methods:
  # * _system_ - returns a reference to the linguistic system in use.
  # * _learning_comparer_ - returns the comparer object to be used
  #   during learning.
  # * _testing_comparer_ - returns the comparer object to be used
  #   during testing.
  module FactoryLearnTestMixin
    # Checks that all required components (system, learning_comparer, and
    # testing_comparer) are defined. Returns true if no errors occurred.
    #
    # Raises a RuntimeError if a component is missing.
    # :call-seq:
    #   check_factory_settings -> true
    def check_factory_settings
      # include the name of the host class in the error messages.
      msg1 = "#{self.class}#build:"
      # If no linguistic system has been specified, raise an error.
      raise "#{msg1} no system specified." if system.nil?

      # If no learning comparer has been specified, raise an error.
      msg2 = 'no learning comparer specified.'
      raise "#{msg1} #{msg2}" if learning_comparer.nil?

      # If no testing comparer has been specified, raise an error.
      msg2 = 'no testing comparer specified.'
      raise "#{msg1} #{msg2}" if testing_comparer.nil?

      true # returns true if no errors were raised
    end
    protected :check_factory_settings

    # Returns a new OTLearn::ParadigmErcLearning object, set to use
    # the provided _selector_ for loser selection.
    # :call-seq:
    #   create_para_erc_learner(selector) -> learner
    def create_para_erc_learner(selector)
      para_erc_learner = OTLearn::ParadigmErcLearning.new
      para_erc_learner.erc_learner = create_erc_learner(selector)
      para_erc_learner
    end
    protected :create_para_erc_learner

    # Returns a new OTLearn::LoserSelectorFromGen object, set to use
    # the provided _comparer_.
    # :call-seq:
    #   create_loser_selector(comparer) -> selector
    def create_loser_selector(comparer)
      LoserSelectorFromGen.new(system, comparer)
    end
    protected :create_loser_selector

    # Returns a new OTLearn::ErcLearning object, set to use
    # the provided _selector_ for loser selection.
    # :call-seq:
    #   create_erc_learner(selector) -> learner
    def create_erc_learner(selector)
      erc_learner = OTLearn::ErcLearning.new
      erc_learner.loser_selector = selector
      erc_learner
    end
    protected :create_erc_learner

    # Returns a new OTLearn::GrammarTest object, set to use
    # the provided _selector_ for loser selection.
    # :call-seq:
    #   create_grammar_tester(selector) -> tester
    def create_grammar_tester(selector)
      tester = OTLearn::GrammarTest.new
      tester.loser_selector = selector
      tester
    end
    protected :create_grammar_tester
  end
end
