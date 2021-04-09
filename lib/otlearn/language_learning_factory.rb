# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/language_learning'
require 'comparer_factory'
require 'otlearn/phonotactic_learning_factory'
require 'otlearn/single_form_learning_factory'
require 'otlearn/contrast_pair_learning_factory'
require 'otlearn/induction_learning_factory'

module OTLearn
  # A factory class for constructing language learner objects
  # using required components. The required components must be
  # provided after the initial object has been constructed.
  # A RuntimeError is raised if the #build method is called
  # before all of the required components have been specified.
  # === Required Components
  # * system - a linguistic system object; set via an attribute.
  # * paradigmatic ranking bias - the ranking bias used in paradigmatic
  #   learning; set via one of para_all_high, para_faith_low,
  #   para_mark_low.
  # * learning compare type - the type of candidate comparison used
  #   during learning; set via one of learn_pool, learn_ctie,
  #   learn_consistent.
  # * testing compare type - the type of candidate comparison used
  #   during grammar testing; set via one of test_pool, test_ctie,
  #   test_consistent.
  #
  # The factory automatically uses a faith_low ranking bias for
  # phonotactic learning and for grammar testing.
  #
  # === Build Outline
  # The factory takes the provided components and builds the intermediate
  # components needed by OTLearn::LanguageLearning objects.
  # * A phonotactic learner, class OTLearn::PhonotacticLearning.
  # * A single form learner, class OTLearn::SingleFormErcLearning.
  # * A contrast pair learner, class OTLearn::ContrastPairLearning.
  # * An induction learner, class OTLearn::InductionLearning.
  # * Finally, an OTLearn::LanguageLearning object is created.
  class LanguageLearningFactory
    # The linguistic system in use.
    attr_accessor :system

    # Returns a new language learning factory object.
    # :call-seq:
    #   LanguageLearningFactory.new -> factory
    def initialize
      @phono_bias = :faith_low
      @test_bias = :faith_low
      @comparer_factory = ComparerFactory.new
      @ph_factory = PhonotacticLearningFactory.new
      @sf_factory = SingleFormLearningFactory.new
      @cp_factory = ContrastPairLearningFactory.new
      @in_factory = InductionLearningFactory.new
    end

    # Sets the paradigmatic learning ranking bias to faith_low.
    def para_faith_low
      @para_bias = :faith_low
      self
    end

    # Sets the paradigmatic learning ranking bias to mark_low.
    def para_mark_low
      @para_bias = :mark_low
      self
    end

    # Sets the paradigmatic learning ranking bias to all_high.
    def para_all_high
      @para_bias = :all_high
      self
    end

    # Sets the learning compare type to pool (pooling the marks).
    def learn_pool
      @learn_type = :pool
      self
    end

    # Sets the learning compare type to ctie (conflicts tie).
    def learn_ctie
      @learn_type = :ctie
      self
    end

    # Sets the learning compare type to consistent (every candidate
    # which could be optimal consistent with the learner's support
    # is returned).
    def learn_consistent
      @learn_type = :ctie
      self
    end

    # Sets the testing compare type to pool (pooling the marks).
    def test_pool
      @test_type = :pool
      self
    end

    # Sets the testing compare type to ctie (conflicts tie).
    def test_ctie
      @test_type = :ctie
      self
    end

    # Sets the learning compare type to consistent (every candidate
    # which could be optimal consistent with the learner's support
    # is returned).
    def test_consistent
      @test_type = :consistent
      self
    end

    # Returns an OTLearn::LanguageLearning object matching
    # the factory-specified settings.
    #
    # Raises a RuntimeError if any of the required components
    # have not been provided.
    # :call-seq:
    #   build -> learner
    def build
      check_factory_settings
      learner = LanguageLearning.new
      phono_comparer = build_comparer(@phono_bias, @learn_type)
      para_comparer = build_comparer(@para_bias, @learn_type)
      test_comparer = build_comparer(@test_bias, @test_type)
      learner.ph_learner =
        build_component(@ph_factory, phono_comparer, test_comparer)
      learner.sf_learner =
        build_component(@sf_factory, para_comparer, test_comparer)
      learner.cp_learner =
        build_component(@cp_factory, para_comparer, test_comparer)
      learner.in_learner =
        build_component(@in_factory, para_comparer, test_comparer)
      learner
    end

    def check_factory_settings
      # include the name of the host class in the error messages.
      msg1 = "#{self.class}#build:"
      # If no linguistic system has been specified, raise an error.
      raise "#{msg1} no system specified." if system.nil?

      # If no paradigmatic ranking bias has been specified, raise an error.
      msg2 = 'no paradigmatic ranking bias specified.'
      raise "#{msg1} #{msg2}" if @para_bias.nil?

      # If no learning compare type has been specified, raise an error.
      msg2 = 'no learning compare type specified.'
      raise "#{msg1} #{msg2}" if @learn_type.nil?

      # If no testing compare type has been specified, raise an error.
      msg2 = 'no testing compare type specified.'
      raise "#{msg1} #{msg2}" if @test_type.nil?

      true # returns true if no errors were raised
    end
    private :check_factory_settings

    def build_comparer(bias, type)
      @comparer_factory.send(bias)
      @comparer_factory.send(type)
      @comparer_factory.build
    end
    private :build_comparer

    def build_component(factory, learn_comparer, test_comparer)
      factory.system = system
      factory.learning_comparer = learn_comparer
      factory.testing_comparer = test_comparer
      factory.build
    end
    private :build_component
  end
end
