# frozen_string_literal: true

# Author: Bruce Tesar

require 'multi_stress/system'
require 'constraint'
require 'clash_lapse/lapse'

# Module ClashLapse contains the linguistic system elements defining the
# ClashLapse linguistic system. ClashLapse builds words from syllables,
# where each syllable has two vocalic features: stress and (vowel) length.
# Each output has zero or more stress-bearing syllables.
module ClashLapse
  # Contains the core elements of the ClashLapse linguistic system.
  # ClashLapse::System is a subclass of MultiStress::System, and differs
  # only in having one additional constraint, Lapse.
  # The public interface is completely inherited from MultiStress::System.
  #
  # ===Non-injected Class Dependencies
  # * ClashLapse::Clash
  # * Constraint
  # * MultiStress::System
  class System < MultiStress::System
    # Returns an array of the constraints. Eight of the nine constraints
    # come from the MultiStress linguistic system.
    def constraint_list
      list = super # Get the constraints of the parent class.
      # Add the additional constraint Clash.
      list << Constraint.new(Lapse.new)
      list
    end
    private :constraint_list
  end
end
