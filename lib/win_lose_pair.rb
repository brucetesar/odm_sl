# frozen_string_literal: true

# Author: Bruce Tesar

require_relative 'erc'
require_relative 'candidate'
require 'forwardable'

# A winner-loser pair has a winner, a loser, and the resulting erc.
# Once created, the winner, loser, and constraint preferences cannot
# be modified.
#
# ==== Instance Methods delegated to class Erc
#
# w?, l?, e?, constraint_list, hash,
# triv_invalid?, triv_valid?, prefs_to_s
class WinLosePair
  extend Forwardable

  # Specify the methods to be automatically delegated to the Erc
  # object referenced in @erc.
  def_delegators :@erc, :w?, :l?, :e?, :constraint_list, :hash
  def_delegators :@erc, :triv_invalid?, :triv_valid?
  def_delegators :@erc, :prefs_to_s

  # The winner of the winner-loser pair.
  attr_reader :winner

  # The loser of the winner-loser pair.
  attr_reader :loser

  # The label of the winner-loser pair.
  attr_accessor :label

  # Stores +winner+ and +loser+, and computes the preference between the two
  # for each constraint.
  #
  # ==== Exceptions
  #
  # RuntimeError - if +winner+ and +loser+ do not have the same input.
  def initialize(winner, loser, label = '')
    if winner.input != loser.input
      raise('The winner and loser do not have the same input.')
    end
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
    "#{label} #{@winner.input} #{@winner.output} #{@loser.output} #{prefs_to_s}"
  end

  # the following methods are private, and can only be called from
  # within the object itself; in this case, called by initialize().
  private

  def set_w(con)
    @erc.set_w(con)
  end

  def set_l(con)
    @erc.set_l(con)
  end

  # For each constraint, determine if it prefers the winner, the loser,
  # or neither, and set the erc appropriately.
  # Called by the constructor +WinLosePair.new+.
  def set_constraint_preferences
    constraint_list.each do |con|
      if @winner.get_viols(con) < @loser.get_viols(con)
        set_w(con)
      elsif @winner.get_viols(con) > @loser.get_viols(con)
        set_l(con)
      end
      # Constraints are e by default in ercs.
    end
  end
end
