# frozen_string_literal: true

# Author: Bruce Tesar

require 'erc'
require 'constraint'

# A compact, easy to define Erc class that is useful for testing.
#
# QuickErc.new([MW,FL]) returns an ERC with two constraints:
# * M1, a markedness constraint preferring the winner
# * F2, a faithfulness constraint preferring the loser
#
# It will automatically create a constraint for each entry in the
# parameter array, with constraint names that are numbered starting
# from 1, left to right.
class QuickErc < Erc
  # Constants for evaluation by constraints
  ML = 'ML'  # prefers the loser
  ME = 'Me'  # no preference
  MW = 'MW'  # prefers the winner
  FL = 'FL'  # prefers the loser
  FE = 'Fe'  # no preference
  FW = 'FW'  # prefers the winner

  # Returns a new QuickErc.
  # === Parameters
  # * evals - an array of constants, with each constant indicating if the
  #   corresponding constraint is markedness (M) or faithfulness (F), and
  #   if the corresponding constraint prefers the winner (W), the loser (L),
  #   or neither (E).
  # * label - a string labeling the quick erc. Default: empty string.
  # :call-seq:
  #   new(evals, label='') -> quick_erc
  def initialize(evals, label = '')
    constraints = []
    super(constraints, label)
    id = 0
    evals.each do |e|
      id += 1
      md = /(M|F)(W|L|e)/.match(e.to_s)
      raise "Failed to match eval #{e} in quick_erc" if md.nil?

      if md[1] == 'F'
        con_type = Constraint::FAITH
        con_name = "F#{id}"
      else
        con_type = Constraint::MARK
        con_name = "M#{id}"
      end
      con = Constraint.new(con_name, con_type)
      constraints << con
      if md[2] == 'W'
        set_w(con)
      elsif md[2] == 'L'
        set_l(con)
      else
        set_e(con)
      end
    end
  end
end
