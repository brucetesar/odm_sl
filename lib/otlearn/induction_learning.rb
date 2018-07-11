# Author: Morgan Moyer / Bruce Tesar

require_relative 'ranking_learning'
require_relative 'data_manip'
require_relative 'grammar_test'
require_relative 'fewest_set_features'
require_relative 'language_learning'
require_relative 'max_mismatch_ranking'

module OTLearn
  
  # This performs certain inductive learning methods when contrast pair
  # learning fails to fully learn the language. The two inductive methods
  # are Max Mismatch Ranking (MMR) and Fewest Set Features (FSF).
  class InductionLearning
    
    # Step subtype constant for fewest set features
    FEWEST_SET_FEATURES = :fewest_set_features
    
    # Step subtype constant for max mismatch learning
    MAX_MISMATCH_RANKING = :max_mismatch_ranking
    
    # The type of learning step
    attr_accessor :step_type

    # The subtype of induction learning step
    attr_reader :step_subtype

    # Creates the induction learning object, and automatically runs
    # induction learning.
    # * +output_list+ - the list of grammatical outputs.
    # * +grammar+ - the grammar that learning will use/modify.
    # * +language_learner+ - passed on to +fewest_set_features_class+.new
    # * +learning_module+ - the module containing the method
    #   #mismatch_consistency_check.  Used for testing (dependency injection).
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    # * +fewest_set_features_class+ - the class of object used for fewest set
    #   features.  Used for testing (dependency injection).
    #
    # :call-seq:
    #   InductionLearning.new(output_list, grammar, language_learner) -> obj
    def initialize(output_list, grammar, language_learner,
        learning_module: OTLearn, grammar_test_class: OTLearn::GrammarTest,
        fewest_set_features_class: OTLearn::FewestSetFeatures,
        max_mismatch_ranking_class: OTLearn::MaxMismatchRanking)
      @output_list = output_list
      @grammar = grammar
      @language_learner = language_learner
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @fewest_set_features_class = fewest_set_features_class
      @max_mismatch_ranking_class = max_mismatch_ranking_class
      @changed = false
      @step_type = LanguageLearning::INDUCTION
      @step_subtype = nil
      @fsf_step = nil
      # Test the words to see which ones currently fail
      @winner_list = @output_list.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      @prior_result = @grammar_test_class.new(@winner_list, @grammar)
      run_induction_learning
      # TODO: change the label below (or eliminate it)
      @test_result = @grammar_test_class.new(@winner_list, @grammar, "Minimal UF Learning")
    end
    
    # Returns true if induction learning made a change to the grammar,
    # returns false otherwise.
    def changed?
      return @changed
    end

    # Returns the Fewest Set Features learning step. If FSF was not run, then
    # it returns nil.
    def fsf_step
      @fsf_step
    end

    # Returns the results of a grammar test after the completion of
    # phonotactic learning.
    def test_result
      @test_result
    end
    
    # Returns true if all words are correctly processed by the grammar;
    # returns false otherwise.
    def all_correct?
      @test_result.all_correct?
    end
    
   # Returns true if anything changed about the grammar
    def run_induction_learning
      # If there are no failed winners, raise an exception, because
      # induction learning shouldn't be called unless there are failed
      # winners to work on.
      if @prior_result.failed_winners.empty? then
        raise RuntimeError.new("InductionLearning invoked with no failed winners.")
      end
      # Check failed winners for consistency, and collect the consistent ones
      consistent_list = @prior_result.failed_winners.select do |word|
        @learning_module.mismatch_consistency_check(@grammar, [word]).grammar.consistent?
      end
      # If there are consistent errors, run MMR on one
      #if consistent_list.empty?
      if consistent_list.empty?
        @step_subtype = FEWEST_SET_FEATURES
        @fsf_step = @fewest_set_features_class.new(@winner_list, @grammar,
          @prior_result, @language_learner)
        @changed = @fsf_step.changed?
      else
        @step_subtype = MAX_MISMATCH_RANKING
        @mmr_step = @max_mismatch_ranking_class.new(consistent_list.first,
          @grammar, @language_learner)
        @mmr_step.run
        @changed = @mmr_step.change?
      end
      return @changed
    end
    protected :run_induction_learning

   end #class Induction_learning
end #module OTLearn
