# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'sl/system'
require 'pas/gen'
require 'constraint'
require 'pas/culm'

# Module PAS contains the linguistic system elements defining the
# Pitch Accent Stress (PAS) linguistic system. PAS builds words from
# syllables, where each syllable has two vocalic features: stress and
# (vowel) length. Each output has at most one stress-bearing syllable
# (stressless outputs are possible).
module PAS
  # Contains the core elements of the PAS (pitch accent stress) linguistic
  # system.
  # PAS::System is a subclass of SL::System, and differs only in the GEN
  # function (it generates candidates with no output stress) and in having
  # one additional constraint, Culm.
  # The public interface is completely inherited from SL::System.
  #
  # ===Non-injected Class Dependencies
  # * PAS::Gen
  # * PAS::Culm
  # * Constraint
  # * SL::System
  class System < SL::System
    # Returns a new instance of PAS::Gen, the GEN function for system PAS.
    # It is initialized with a reference to the current system object.
    def gen_instance
      Gen.new(self)
    end
    private :gen_instance

    # Returns an array of the constraints. Six of the seven constraints
    # come from the SL linguistic system.
    def constraint_list
      list = super # Get the constraints of the parent class.
      # Add the additional constraint Culm.
      list << Constraint.new(Culm.new)
      list
    end
    private :constraint_list
  end
end
