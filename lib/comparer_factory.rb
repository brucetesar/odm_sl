# frozen_string_literal: true

# Author: Bruce Tesar

require 'ranking_bias_all_high'
require 'otlearn/ranking_bias_some_low'
require 'otlearn/faith_low'
require 'otlearn/mark_low'
require 'rcd_runner'
require 'ranker'
require 'compare_pool'
require 'compare_ctie'
require 'compare_consistency'

# A factory class for constructing comparer objects according to various
# specifications. Will also return Rcd_Runner objects corresponding
# to the ranking bias specifications.
class ComparerFactory
  # Returns a new ComparerFactory object.
  def initialize
    @ranking_bias = nil
    @compare_type = nil
  end

  # Sets the factory to use the all high ranking bias.
  # Every constraint is ranked as high as possible.
  def all_high
    @ranking_bias = :all_high
  end

  # Sets the factory to use the faith low ranking bias.
  # Markedness constraints are ranked as high as possible, while
  # faithfulness constraints are ranked as low as possible.
  def faith_low
    @ranking_bias = :faith_low
  end

  # Sets the factory to use the mark low ranking bias.
  # Faithfulness constraints are ranked as high as possible, while
  # markedness constraints are ranked as low as possible.
  def mark_low
    @ranking_bias = :mark_low
  end

  # Set the factory to use the POOL comparison type.
  def pool
    @compare_type = :pool
  end

  # Set the factory to use the CTie comparison type.
  def ctie
    @compare_type = :ctie
  end

  # Set the factory to use the Consistent comparison type.
  def consistent
    @compare_type = :consistent
  end

  # Constructs a comparer according to the current factory settings,
  # and returns it.
  # Also constructs a ranker, and stores the associated rcd_runner,
  # if a ranking bias is specified, whether or not a ranking bias
  # is needed by the comparer.
  def create_comparer
    if @compare_type == :pool
      ComparePool.new(Ranker.new(rcd_runner))
    elsif @compare_type == :ctie
      CompareCtie.new(Ranker.new(rcd_runner))
    elsif @compare_type == :consistent
      CompareConsistency.new
    else
      raise 'ComparerFactory: no valid compare type has been set.'
    end
  end

  # The RCD runner corresponding to the learning bias. Nil if no
  # ranking bias has been set.
  def rcd_runner
    bias = if @ranking_bias == :faith_low
             OTLearn::RankingBiasSomeLow.new(OTLearn::FaithLow.new)
           elsif @ranking_bias == :mark_low
             OTLearn::RankingBiasSomeLow.new(OTLearn::MarkLow.new)
           elsif @ranking_bias == :all_high
             RankingBiasAllHigh.new
           else
             no_bias_error
           end
    RcdRunner.new(bias)
  end

  # Raises an exception indicating that a bias type is required
  # but has not been specified.
  def no_bias_error
    msg1 = 'ComparerFactory#rcd_runner:'
    msg2 = 'but no valid ranking bias has been set.'
    raise "#{msg1} #{msg2}"
  end
  protected :no_bias_error
end
