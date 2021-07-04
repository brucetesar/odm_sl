# frozen_string_literal: true

# Author: Bruce Tesar

module SL
  # The faithfulness constraint IdentStress assesses one violation for
  # each pair of IO-corresponding syllables where one or the other but
  # not both has main stress.
  class IdentStress
    # The name of the constraint: IDStress.
    attr_reader :name

    # The the type of the constraint: FAITH.
    attr_reader :type

    # Returns an IdentStress object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'IDStress'
      @type = Constraint::FAITH
    end

    # Evaluates the candidate _cand_. Returns the number of violations,
    # a non-negative integer.
    # :call-seq:
    #   eval_candidate(cand) -> int
    def eval_candidate(cand)
      viol_count = 0
      cand.input.each do |in_syl|
        unless in_syl.stress_unset?
          out_syl = cand.io_out_corr(in_syl)
          viol_count += 1 if in_syl.main_stress? != out_syl.main_stress?
        end
      end
      viol_count
    end
  end
end
