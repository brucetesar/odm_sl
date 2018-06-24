# Author: Bruce Tesar

require_relative 'ercs_image'

# A CT_image object represents a comparative tableau in a spreadsheet-like
# table format.
class CT_image < ERCs_image

  NUMBER_COL = COL1 #:nodoc:
  INPUT_COL = NUMBER_COL + 1 #:nodoc:
  WINNER_COL = INPUT_COL + 1 #:nodoc:
  LOSER_COL = WINNER_COL + 1 #:nodoc:
  PRE_CON_COLUMNS = 4 #:nodoc:

  # Constructs a new CT_image from an erc list / constraint list pair.
  #
  # * +ercs+ - a list of the ercs/winner-loser pairs of the CT,
  #   in the order in which the erc rows should appear.
  # * +constraints+ - a list of constraints, in the order in which
  #   the constraint columns should appear.
  def initialize(ercs, constraints)
    self.first_con_col = PRE_CON_COLUMNS + 1
    super()
    # process the method parameter
    self.ercs = ercs
    self.constraints = constraints
    construct_image
  end

  # Uses the given lists of ercs and constraints,
  # and constructs the corresponding CT sheet.
  def construct_image
    construct_constraint_columns_image
    construct_pre_constraint_columns_image
  end
  protected :construct_image

  # Construct the sheet image for the pre-constraint columns, i.e.,
  # the columns for ERC#, Input, Winner, Loser.
  def construct_pre_constraint_columns_image
    # first row contains the column headers
    sheet[heading_row,NUMBER_COL] = "ERC\#"
    sheet[heading_row,INPUT_COL] = "Input"
    sheet[heading_row,WINNER_COL] = "Winner"
    sheet[heading_row,LOSER_COL] = "Loser"
    # add the pre-constraint erc info to the sheet
    row = heading_row
    ercs.each do |erc|
      row += 1
      sheet[row,NUMBER_COL] = erc.label
      if erc.respond_to?(:winner) then # pair contains a winner and a loser
        sheet[row,INPUT_COL] = erc.winner.input.to_s
        sheet[row,WINNER_COL] = erc.winner.output.to_s
        sheet[row,LOSER_COL] = erc.loser.output.to_s
      else
        sheet[row,INPUT_COL] = nil
        sheet[row,WINNER_COL] = nil
        sheet[row,LOSER_COL] = nil
      end
    end
  end
  protected :construct_pre_constraint_columns_image

end # class CT_image
