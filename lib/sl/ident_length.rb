# frozen_string_literal: true

# Author: Bruce Tesar

module SL
  # The faithfulness constraint IdentLength assesses one violation for
  # each pair of IO-corresponding syllables that has differing values
  # for their length feature.
  class IdentLength
    # The name of the constraint: IDLength.
    attr_reader :name

    # The the type of the constraint: FAITH.
    attr_reader :type

    # Returns an IdentLength object.
    # :call-seq:
    #   new -> ident_length
    def initialize
      @name = 'IDLength'
      @type = Constraint::FAITH
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      viol_count = 0
      cand.input.each do |in_syl|
        unless in_syl.length_unset?
          out_syl = cand.io_out_corr(in_syl)
          viol_count += 1 if in_syl.long? != out_syl.long?
        end
      end
      viol_count
    end
  end
end
