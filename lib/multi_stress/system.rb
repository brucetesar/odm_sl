# frozen_string_literal: true

# Author: Bruce Tesar

require 'pas/system'
require 'multi_stress/gen'
require 'constraint'
require 'multi_stress/clash'

# Module MultiStress contains the linguistic system elements defining the
# MultiStress linguistic system. MultiStress builds words from syllables,
# where each syllable has two vocalic features: stress and (vowel) length.
# Each output has zero or more stress-bearing syllables.
module MultiStress
  # Contains the core elements of the MultiStress linguistic system.
  # MultiStress::System is a subclass of PAS::System, and differs only in
  # the GEN function (it generates candidates with multiple output
  # stresses) and in having one additional constraint, Clash.
  # The public interface is completely inherited from PAS::System.
  #
  # ===Non-injected Class Dependencies
  # * MultiStress::Gen
  # * MultiStress::Clash
  # * Constraint
  # * PAS::System
  class System < PAS::System
    # Returns a new instance of MultiStress::Gen, the GEN function for
    # system MultiStress. It is initialized with a reference to the current
    # system object.
    def gen_instance
      Gen.new(self)
    end
    private :gen_instance

    # Returns an array of the constraints. Seven of the eight constraints
    # come from the PAS linguistic system.
    def constraint_list
      list = super # Get the constraints of the parent class.
      # Add the additional constraint Clash.
      list << Constraint.new(Clash.new)
      list
    end
    private :constraint_list
  end
end
