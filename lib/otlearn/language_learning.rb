# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/phonotactic_learning'
require 'otlearn/single_form_learning'
require 'otlearn/contrast_pair_learning'
require 'otlearn/induction_learning'
require 'otlearn/error_step'
require 'otlearn/learning_result'

module OTLearn
  # A LanguageLearning object instantiates a particular instance of
  # language learning. Learning is executed via the method #learn,
  # given a set of outputs (the data to be learned from), and a starting
  # grammar (which will likely be altered during the course of learning).
  # The method #learn returns a learning result object.
  #
  # The major components of the learner can be assigned externally via
  # the attributes:
  # * ph_learner - phonotactic learner
  # * sf_learner - single form learner
  # * cp_learner - contrast pair learner
  # * in_learner - induction learner
  # Any components not set externally will be assigned a default object
  # the first time \#learn is called.
  #
  # The learning proceeds in the following stages, in order:
  # * Phonotactic learning.
  # * Repeat until the language is learned or no further change can be made.
  #   * Single form learning. If learning is completed, stop looping.
  #   * Contrast pair learning.
  #   * If contrast pair learning fails, try induction learning.
  # After each learning step, a learning step object is stored.
  # The ordered list of learning steps is obtainable from
  # the learning result via #step_list.
  # ===References
  # Tesar 2014. <em>Output-Driven Phonology</em>.
  class LanguageLearning
    # Phonotactic learner
    attr_accessor :ph_learner

    # Single form learner
    attr_accessor :sf_learner

    # Contrast pair learner
    attr_accessor :cp_learner

    # Induction learner
    attr_accessor :in_learner

    # Constructs a language learning simulation object.
    # :call-seq:
    #   LanguageLearning.new -> language_learning
    #--
    # warn_output is a dependency injection used for testing. It is
    # the IO channel to which warnings are written (normally $stderr).
    def initialize(warn_output: nil)
      # The default output channel for warnings is $stderr.
      @warn_output = warn_output || $stderr
    end

    # Runs the learning simulation, and returns a learning result object.
    # :call-seq:
    #   learn(output_list, grammar) -> learning_result
    def learn(output_list, grammar)
      # step_list is an instance variable so that it remains easily
      # accessible if an exception is raised, and then caught by
      # #error_protected_execution.
      @step_list = []
      error_protected_execution(grammar.label) do
        execute_learning(output_list, grammar)
      end
      LearningResult.new(@step_list, grammar)
    end

    # Coordinates the execution of the learning steps. First, it executes
    # phonotactic learning. If learning is not yet complete, then it
    # proceeds to paradigmatic learning.
    # Returns true if learning was successful, false otherwise.
    def execute_learning(output_list, grammar)
      optional_defaults
      @step_list << @ph_learner.run(output_list, grammar)
      paradigmatic_loop(output_list, grammar) unless last_step.all_correct?
      last_step.all_correct?
    end
    private :execute_learning

    # Loop paradigmatic learning until learning is complete or there is
    # no change:
    # * single form learning
    # * contrast pair learning
    # * if no contrast pair, induction learning
    def paradigmatic_loop(output_list, grammar)
      # Loop until learning is complete.
      until last_step.all_correct?
        @step_list << @sf_learner.run(output_list, grammar)
        break if last_step.all_correct?

        @step_list << @cp_learner.run(output_list, grammar)
        next if last_step.changed?

        # If CP learning failed, try induction learning.
        @step_list << @in_learner.run(output_list, grammar)
        # If CP and induction failed, quit looping.
        break unless last_step.changed?
      end
    end
    private :paradigmatic_loop

    # Returns the most recent learning step.
    def last_step
      @step_list[-1]
    end
    private :last_step

    # Checks each of the learner components. For each component,
    # if a learner object has not been assigned externally,
    # assign the default. Returns nil.
    def optional_defaults
      @ph_learner ||= PhonotacticLearning.new
      @sf_learner ||= SingleFormLearning.new
      @cp_learner ||= ContrastPairLearning.new
      @in_learner ||= InductionLearning.new
      nil # arbitrary return value
    end
    private :optional_defaults

    # Calls provided block, and rescues an exception if one arises.
    # Returns the value returned by block if no exception is raised,
    # otherwise it returns the value returned by the exception handler.
    def error_protected_execution(label)
      yield
    rescue RuntimeError => e
      handle_exception(rterror_msg(e, label))
    end
    private :error_protected_execution

    # Handles an exception by creating a new error step, adding it
    # to the step list, writing a warning to the warning output
    # channel, and returning false (indicating learning failed).
    def handle_exception(msg)
      @step_list << ErrorStep.new(msg)
      @warn_output.puts msg # write to the warning output channel
      false # exception means learning has failed
    end
    private :handle_exception

    # Returns the warning message for a RuntimeError exception
    # raised during learning.
    def rterror_msg(exception, label)
      "Error with #{label}: #{exception}"
    end
    private :rterror_msg
  end
end
