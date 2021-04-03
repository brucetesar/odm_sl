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
  # :call-seq:
  #   ComparerFactory.new -> factory
  def initialize
    @ranking_bias = nil
    @compare_type = nil
  end

  # Sets the factory to use the all high ranking bias.
  # Every constraint is ranked as high as possible.
  # Returns a reference to self.
  def all_high
    @ranking_bias = :all_high
    self
  end

  # Sets the factory to use the faith low ranking bias.
  # Markedness constraints are ranked as high as possible, while
  # faithfulness constraints are ranked as low as possible.
  # Returns a reference to self.
  def faith_low
    @ranking_bias = :faith_low
    self
  end

  # Sets the factory to use the mark low ranking bias.
  # Faithfulness constraints are ranked as high as possible, while
  # markedness constraints are ranked as low as possible.
  # Returns a reference to self.
  def mark_low
    @ranking_bias = :mark_low
    self
  end

  # Set the factory to use the POOL comparison type.
  # Returns a reference to self.
  def pool
    @compare_type = :pool
    self
  end

  # Set the factory to use the CTie comparison type.
  # Returns a reference to self.
  def ctie
    @compare_type = :ctie
    self
  end

  # Set the factory to use the Consistent comparison type.
  # Returns a reference to self.
  def consistent
    @compare_type = :consistent
    self
  end

  # Builds a comparer according to the current factory settings, and
  # returns it. Raise a RuntimeError if no compare type has been set.
  # :call-seq:
  #   build -> comparer
  def build
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

  # Returns a new RCD runner, which uses the currently set ranking bias.
  # Raises a RuntimeError if no ranking bias has been set.
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
  private :no_bias_error
end
