# Author: Bruce Tesar
# 

require_relative '../feature'

module SL

  # A length feature is a Feature of type LENGTH.
  # It has two possible feature values, represented
  # by the constants LONG and SHORT.
  class Length_feat < Feature
    #-- Symbols are used as lightweight, readable constants ++

    # Feature type vowel length
    LENGTH = :length
    # Feature value long vowel
    LONG = :long
    # Feature value short vowel
    SHORT = :short

    # Returns a new length feature, with the feature value unset.
    def initialize
      super(LENGTH) # Pass the feature type to Feature#initialize.
    end

    # Returns true if the feature instance is long; false otherwise.
    def long?
      self.value == LONG
    end

    # Returns true if the feature instance is short; false otherwise.
    def short?
      self.value == SHORT
    end

    # Sets the feature to the value LONG.
    def set_long
      self.value = LONG
      self
    end

    # Sets the the feature to the value SHORT.
    def set_short
      self.value = SHORT
      self
    end

    # Returns a string representation of the feature:
    # "length=<value>"
    def to_s
      return "length=unset" if unset?
      return "length=long" if long?
      return "length=short" if short?
    end

    #-- Generic interface ++

    # Passes each possible value for this feature to the given code block,
    # one at a time (iterator style). This generic interface should be
    # used by all feature types.
    def each_value
      yield SHORT
      yield LONG
    end

  end # class Length_feat

end # module SL