# frozen_string_literal: true

# Author: Bruce Tesar

require 'erc'
require 'constraint'

module QuickErc
  # Constants for evaluation by constraints
  ML = 'ML'  # prefers the loser
  ME = 'Me'  # no preference
  MW = 'MW'  # prefers the winner
  FL = 'FL'  # prefers the loser
  FE = 'Fe'  # no preference
  FW = 'FW'  # prefers the winner

  # This is a method for testing. It allows an ERC of a certain form to
  # be constructed in a single, readable line.
  #
  # Test.quick_erc([MW,FL]) returns an ERC with two constraints:
  # * M1, a markedness constraint preferring the winner
  # * F2, a faithfulness constraint preferring the loser
  def self.quick_erc(evals, label = '')
    constraints = []
    erc = Erc.new(constraints, label)
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
        erc.set_w(con)
      elsif md[2] == 'L'
        erc.set_l(con)
      else
        erc.set_e(con)
      end
    end
    erc
  end
end
