# frozen_string_literal: true

# Author: Bruce Tesar

require 'constraint'
require 'erc_list'

# Contains classes for a linguistic system read in entirely from
# table-like files, where all constraint names and candidate contents are
# listed out as strings.
module OTGeneric
  # Contains methods for converting an ERC list from an "array of strings"
  # representation to an ErcList/Erc object representation.
  class ErcReader
    # Returns a new ErcReader object.
    # :call-seq:
    #   ErcReader.new -> reader
    def initialize; end

    # Takes an array of column headers _headers_, and an array of arrays
    # _data_, and returns an equivalent ErcList of ERCs.
    def arrays_to_erc_list(headers, data)
      constraints = convert_headers_to_constraints(headers)
      convert_data_to_ercs(data, constraints)
    end

    # Converts the header row of array representation of ERCs, ignores
    # the first cell (the column of ERC labels), and for each subsequent
    # value creates a Constraint object.
    # If a constraint's name begins with "F:", then it is set as a
    # Faithfulness constraint; otherwise, it is set as a Markedness
    # constraint.
    # The ID for each constraint is set to nil, so it doesn't appear when
    # #to_s is called..
    # Returns an array of constraints.
    def convert_headers_to_constraints(headers)
      constraints = []
      con_headers = headers[1..-1] # all but first cell
      con_headers.each do |head|
        # A Faith constraint starts with "F:"
        con_type = if /^F:/ =~ head
                     Constraint::FAITH
                   else
                     Constraint::MARK
                   end
        constraints << Constraint.new(head, con_type)
      end
      constraints
    end
    private :convert_headers_to_constraints

    # Converts each data row to an Erc object. Returns an ErcList of
    # the ERCs.
    def convert_data_to_ercs(data, constraints)
      erc_list = ErcList.new(constraints)
      data.each do |row|
        erc = Erc.new(constraints)
        erc.label = row[0]
        evals = row[1..-1] # all but first column
        evals.each_with_index do |eval, i|
          if eval == 'W'
            erc.set_w(constraints[i])
          elsif eval == 'L'
            erc.set_l(constraints[i])
          end
        end
        erc_list.add(erc)
      end
      erc_list
    end
    private :convert_data_to_ercs
  end
end
