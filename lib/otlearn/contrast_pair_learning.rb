# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/contrast_pair_step'
require 'otlearn/contrast_pair_generator'
require 'otlearn/paradigm_erc_learning'
require 'otlearn/feature_value_learning'
require 'otlearn/grammar_test'

module OTLearn
  # Instantiates contrast pair learning. Any results of learning are
  # realized as side effect changes to the grammar.
  class ContrastPairLearning
    # The paradigmatic ERC learner. Default: ParadigmErcLearning.new
    attr_accessor :para_erc_learner

    # The feature value learner. Default: FeatureValueLearning.new
    attr_accessor :feature_learner

    # The grammar testing object. Default: GrammarTest.new.
    attr_accessor :grammar_tester

    # Constructs a contrast pair learning object.
    # :call-seq:
    #   ContrastPairLearning.new -> learner
    #--
    # cp_gen_class is a dependency injection used for testing.
    def initialize(cp_gen_class: nil)
      @cp_gen_class = cp_gen_class
    end

    # Select a contrast pair, and process it, attempting to set
    # underlying features. If any features are set, check for any newly
    # available ranking information. Returns a contrast pair step.
    # :call-seq:
    #   run(output_list, grammar) -> step
    def run(output_list, grammar)
      check_defaults
      # Create an external iterator for contrast pairs.
      # Important: create a new cp enumerator each time #run is called.
      cp_enum = construct_cp_enumerator(output_list, grammar)
      # Process contrast pairs until one is found that sets an underlying
      # feature, or until all contrast pairs have been processed.
      contrast_pair, set_feature_list =
        process_contrast_pairs(cp_enum, grammar)
      # For each newly set feature, see if any new ranking information
      # is now available.
      set_feature_list.each do |set_f|
        @para_erc_learner.run(set_f, grammar, output_list)
      end
      # Package the results in a contrast pair step object.
      changed = !set_feature_list.empty?
      test_result = @grammar_tester.run(output_list, grammar)
      ContrastPairStep.new(test_result, changed, contrast_pair)
    end

    # Assigns default values for the grammar tester, paradigm ERC
    # learner, feature value learner, and contrast pair generator class
    # if they have not already been assigned.
    def check_defaults
      @grammar_tester ||= GrammarTest.new
      @para_erc_learner ||= ParadigmErcLearning.new
      @feature_learner ||= FeatureValueLearning.new
      @cp_gen_class ||= ContrastPairGenerator
      nil
    end
    private :check_defaults

    # Iterate over contrast pairs until one is found that permits
    # setting at least one unset feature. Returns an array containing
    # the contrast pair and array of the newly set features.
    def process_contrast_pairs(cp_enum, grammar)
      # NOTE: loop silently rescues StopIteration, so if cp_enum runs
      # out of contrast pairs, loop simply terminates, and execution
      # continues below it.
      loop do
        contrast_pair = cp_enum.next
        # Process the contrast pair, and return a list of any features
        # that were newly set during the processing.
        set_feature_list = @feature_learner.run(contrast_pair, grammar)
        # If an underlying feature was set, return the cp and set values.
        # Otherwise, continue processing contrast pairs.
        return [contrast_pair, set_feature_list] \
          unless set_feature_list.empty?
      end
      # No contrast pair permitted feature setting. Return nil for the
      # contrast pair, and an empty array of newly set features.
      [nil, []]
    end
    private :process_contrast_pairs

    # Returns an Enumerator that iterates over valid contrast pairs,
    # defined from _output_list_ and _grammar_.
    def construct_cp_enumerator(outputs, grammar)
      cp_generator = @cp_gen_class.new(outputs, grammar)
      cp_generator.grammar_tester = grammar_tester
      cp_generator.to_enum
    end
    private :construct_cp_enumerator
  end
end
