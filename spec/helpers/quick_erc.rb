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
# It will automatically create a constraint for each code in the
# parameter array, with constraint names that are numbered starting
# from 1, left to right.
#
# The codes defining the constraints, e.g., MW, are defined as constants.
class QuickErc < Erc
  # Constraint Codes
  ML = 'ML'  # markedness, prefers the loser
  ME = 'Me'  # markedness, no preference
  MW = 'MW'  # markedness, prefers the winner
  FL = 'FL'  # faithfulness, prefers the loser
  FE = 'Fe'  # faithfulness, no preference
  FW = 'FW'  # faithfulness, prefers the winner

  # Returns a new QuickErc.
  # === Parameters
  # * codes - an array of constants, with each constant indicating if the
  #   corresponding constraint is markedness (M) or faithfulness (F), and
  #   if the corresponding constraint prefers the winner (W), the loser (L),
  #   or neither (E).
  # * label - a string labeling the quick erc. Default: empty string.
  # :call-seq:
  #   new(codes, label='') -> quick_erc
  def initialize(codes, label = '')
    constraints = []
    super(constraints, label)
    id = 0
    codes.each do |code|
      id += 1
      con_type, con_eval = decompose_code(code)
      con = construct_constraint(id, con_type)
      constraints << con
      set_evaluation(con, con_eval)
    end
  end

  # Decomposes a code, such as MW, into its component parts:
  # * the constraint type: M or F
  # * the evaluation: W or e or L
  # Returns a two-element array, [type, eval]
  def decompose_code(code)
    md = /([MF])([WLe])/.match(code.to_s)
    raise "Failed to match code #{code} in QuickErc" if md.nil?

    [md[1], md[2]]
  end
  private :decompose_code

  # Returns a new Constraint with the type indicated by _type_, and a
  # name string that is the type code followed by the _id_.
  def construct_constraint(id, type)
    if type == 'F'
      Constraint.new("F#{id}", Constraint::FAITH)
    else
      Constraint.new("M#{id}", Constraint::MARK)
    end
  end
  private :construct_constraint

  # Sets the erc's evaluation for constraint _con_ to match _eval_.
  def set_evaluation(con, eval)
    case eval
    when 'W'
      set_w(con)
    when 'L'
      set_l(con)
    else
      set_e(con)
    end
    nil
  end
  private :set_evaluation
end
