# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/consistency_checker'
require 'word_search'
require 'feature_value_pair'
require 'word_values_package'

module OTLearn
  # An object of this class, when method #run is called, takes a winner
  # that is mismatch-inconsistent (the max-mismatch input for the word
  # cannot be mapped to the output by any ranking consistent with the
  # grammar), and searches for any unset features that, if set, would
  # make the word mismatch-consistent. This class works in support of
  # inductive learning, in particular in support of Fewest Set Features.
  class InductiveFeatureValueFinder
    # Returns a new inductive feature value finder.
    # :call-seq:
    #   new -> finder
    #--
    # Named parameters _consistency_checker, _word_search_, and
    # _fv_pair_class_ are dependency injections used for testing.
    def initialize(consistency_checker: nil, word_search: nil,
                   fv_pair_class: nil)
      @consistency_checker = consistency_checker
      @word_search = word_search
      @fv_pair_class = fv_pair_class
    end

    # Assign default values to any dependencies that have not been assigned
    # via the constructor.
    def check_defaults
      @consistency_checker ||= ConsistencyChecker.new
      @word_search ||= WordSearch.new
      @fv_pair_class ||= FeatureValuePair
      nil
    end
    private :check_defaults

    # Returns an array of packages, each containing the winner and a
    # minimal set of successful feature values.
    # :call-seq:
    #   run(winner, grammar, test_result) -> array
    def run(winner, grammar, test_result)
      check_defaults
      # Duplicate the winner, so that the input can be altered.
      winner_dup = grammar.parse_output(winner.output)
      # Find all unset features, then find which ones are successful
      # (render the winner mismatch-consistent).
      unset_uf_features =
        @word_search.find_unset_features_in_words([winner_dup], grammar)
      consistent_feature_val_list =
        consistent_feature_values(winner_dup, unset_uf_features,
                                  grammar, test_result)
      # Return an array of WordValuesPackage objects for the successful
      # features.
      consistent_feature_val_list.map do |values|
        WordValuesPackage.new(winner, values)
      end
    end

    # Returns a list of lists of feature-value pairs. Each list of
    # feature-value pairs is such that, if all of the features in the list
    # were set to the indicated values, then the winner would become
    # mismatch-consistent with the grammar.
    def consistent_feature_values(winner, unset_features, grammar,
                                  test_result)
      consistent_feature_val_list = []
      # Test each unset feature, accumulate the successful (consistent) ones.
      unset_features.each do |ufeat|
        ufeat_val_pair = test_unset_feature(winner, ufeat, grammar,
                                            test_result)
        consistent_feature_val_list << [ufeat_val_pair] \
          unless ufeat_val_pair.nil?
      end
      consistent_feature_val_list
    end
    private :consistent_feature_values

    # Temporarily assigns the unset feature _ufeat_ the value that it
    # has in the output for _winner_. It then tests to see if that
    # makes the winner mismatch-consistent. If the resulting winner is
    # mismatch-consistent, the feature-value pair of the unset feature
    # and its output-derived value is returned. If the resulting winner
    # is not mismatch-consistent, then nil is returned.
    def test_unset_feature(winner, ufeat, grammar, test_result)
      # Set the target feature (temporarily) to the value of its output
      # correspondent in the winner.
      ufeat.value = winner.out_feat_corr_of_uf(ufeat).value
      # Collect all of the successful winners thus far observed, and
      # add the target winner with the target feature set.
      word_list = test_result.success_winners.dup
      word_list << winner
      output_list = word_list.map(&:output)
      # If the winner is now mismatch-consistent, return the feature-value
      # pair combining the target unset feature and its output-derived value.
      # Return nil if the output list is inconsistent with the grammar.
      val_pair = nil
      if @consistency_checker.mismatch_consistent?(output_list, grammar)
        val_pair = @fv_pair_class.new(ufeat, ufeat.value)
      end
      # In any event, unset the temporarily set feature.
      ufeat.unset
      val_pair
    end
    private :test_unset_feature
  end
end
