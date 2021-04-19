# frozen_string_literal: true

# Author: Bruce Tesar

require 'erc'
require 'candidate'
require 'forwardable'

# A winner-loser pair has a winner, a loser, and the resulting erc.
# Once created, the winner, loser, and constraint preferences cannot
# be modified.
#
# ==== Instance Methods delegated to class Erc
#
# w?, l?, e?, constraint_list, hash,
# triv_invalid?, triv_valid?, pref_to_s
class WinLosePair
  extend Forwardable

  # Specify the methods to be automatically delegated to the Erc
  # object referenced in @erc.
  def_delegators :@erc, :w?, :l?, :e?, :constraint_list, :hash
  def_delegators :@erc, :triv_invalid?, :triv_valid?, :pref_to_s

  # The winner of the winner-loser pair.
  attr_reader :winner

  # The loser of the winner-loser pair.
  attr_reader :loser

  # The label of the winner-loser pair.
  attr_accessor :label

  # Stores _winner_ and _loser_, and computes the preference between
  # the two for each constraint.
  #
  # Raises a RuntimeError if _winner_ and _loser_ do not have the
  # same input.
  # :call-seq:
  #   new(winner, loser, label) -> pair
  def initialize(winner, loser, label = '')
    msg = 'The winner and loser do not have the same input.'
    raise(msg) if winner.input != loser.input

    @winner = winner
    @loser = loser
    @label = label
    @erc = Erc.new(winner.constraint_list)
    set_constraint_preferences
  end

  # Returns a string of the form:
  #
  #   label input winner_output loser_output constraint_preferences
  def to_s
    cand_str = "#{@winner.input} #{@winner.output} #{@loser.output}"
    "#{label} #{cand_str} #{@erc}"
  end

  # For each constraint, determine if it prefers the winner, the loser,
  # or neither, and set the erc appropriately.
  def set_constraint_preferences
    constraint_list.each do |con|
      if @winner.get_viols(con) < @loser.get_viols(con)
        @erc.set_w(con)
      elsif @winner.get_viols(con) > @loser.get_viols(con)
        @erc.set_l(con)
      end
      # Constraints are e by default in ercs.
    end
  end
  private :set_constraint_preferences
end
