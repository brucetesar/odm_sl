# Author: Morgan Moyer

require_relative 'data_manip'
require_relative 'learning_exceptions'
require_relative 'mmr_exceptions'
require_relative 'ranking_learning'

module OTLearn
  
 # MaxMismatchRanking takes winners that are failing Initial Word Evaluation
 # (where the candidate created using the maximally dissimilar input paired 
 # with the output is error testing), and creates a winner-loser pair using the 
 # error. Then, this WL pair is added to the learner's support for inconsistency 
 # testing. If the WL pair is consistent with the learner's support, then the learner
 # can assume that this WL pair encodes missing ranking information.
 # If the WL pair is inconsistent, then the learner should attempt to set an
 # underlying feature, using FewestSetFeatures.
 # 
 # This class would typically be invoked when neither single form learning nor
 # contrast pairs are able to make further progress, yet learning is
 # not yet complete, suggesting that a paradigmatic subset relation is present.
  class MaxMismatchRanking
    
    # Initializes a new object, *and* automatically execute
    # the max mismatch ranking algorithm.
    # * +failed_winner_list+ is the list of *consistent* failed winners that
    #   are candidates for use in MMR.
    # * +grammar+ is the current grammar of the learner.
    # * +language_learner+ included in an exception that is raised.
    # * +ranking_learning_module+ - the module containing the methods
    #   #mismatches_input_to_output and #ranking_learning_faith_low.
    #   Used for testing (dependency injection).
    def initialize(failed_winner_list, grammar, language_learner,
        ranking_learning_module: OTLearn)
      @grammar = grammar
      @failed_winner_list = failed_winner_list
      @language_learner = language_learner
      @ranking_learning_module = ranking_learning_module
      @newly_added_wl_pairs = []
      @failed_winner = nil
      @changed = false
      # automatically execute MMR
      run
    end
    
    # Returns the ERC that the algorithm has created
    def newly_added_wl_pairs
      return @newly_added_wl_pairs
    end
    
    # Returns the failed winner that was used with max mismatch ranking.
    def failed_winner
      return @failed_winner
    end
    
    # Returns true if MaxMismatchRanking has found a consistent WL pair
    def changed?
      return @changed
    end
    
    # Executes the Max Mismatch Ranking algorithm.
    # 
    # The learner chooses a single consistent failed winner from the list.
    # For that failed winner, the learner takes the input with all  
    # unset features set opposite their surface value and creates a candidate.
    # Then, MRCD is used to construct the ERCs necessary to make that
    # candidate grammatical.
    # 
    # Returns True if the consistent max mismatch candidate provides
    # new ranking information. Raises an exception if it does not provide new 
    # ranking information.
    def run
      choose_failed_winner
      mrcd_result = nil
      @ranking_learning_module.mismatches_input_to_output(@failed_winner) do |cand|
        mrcd_result = @ranking_learning_module.ranking_learning_faith_low_no_mod([cand], @grammar)
      end
      @newly_added_wl_pairs = mrcd_result.added_pairs
      @changed = mrcd_result.any_change?
      raise MMREx.new(@failed_winner, @language_learner), ("A failed consistent" +
        " winner did not provide new ranking information.") unless @changed
      return @changed
    end
    protected :run
    
    # Choose, from among the consistent failed winners, the failed winner to
    # use with MMR.
    def choose_failed_winner
      @failed_winner = @failed_winner_list.first      
    end
    protected :choose_failed_winner
    
  end # class MaxMismatchRanking
end # module OTLearn