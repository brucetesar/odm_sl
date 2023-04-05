# frozen_string_literal: true

# Author: Bruce Tesar

require 'sl/stress'
require 'sl/length'

module SL
  # A syllable for the SL system has two features, stress and length. It
  # also can have an affiliated morpheme.
  #
  # Learning algorithms are expected to use the "generic" interface,
  # consisting of the methods #each_feature() and #get_feature(). The
  # method #each_feature() is an iterator that yields each feature of the
  # syllable in turn, allowing other routines to work with syllables
  # without knowing in advance how many or what types of features they
  # have.
  class Syllable
    # Returns the morpheme that this syllable is affiliated with.
    attr_reader :morpheme

    # Returns a new syllable, with unset features, and an empty
    # string for the morpheme.
    # :call-seq:
    #   new() -> syllable
    def initialize
      @stress = Stress.new
      @length = Length.new
      @morpheme = ''
    end

    # A duplicate has copies of the features, so that they may be altered
    # independently of the original syllable's features.
    def dup
      dup_syl = self.class.new
      dup_syl.set_morpheme(morpheme)
      each_feature do |f|
        dup_syl.set_feature(f.type, f.value)
      end
      dup_syl
    end

    # Protected accessors, only used for #==()
    attr_reader :stress, :length # :nodoc:
    protected :stress, :length # :nodoc:

    # Returns true if this syllable matches _other_ in the values
    # the stress feature, the length feature, and morpheme identity.
    def ==(other)
      return false unless @stress == other.stress
      return false unless @length == other.length
      return false unless @morpheme == other.morpheme

      true
    end

    # The same as ==(other).
    def eql?(other)
      self == other
    end

    # Returns true if the syllable's stress feature has the value
    # main_stress.
    def main_stress?
      @stress.main_stress?
    end

    # Returns true if the syllable's stress feature has the value
    # unstressed.
    def unstressed?
      @stress.unstressed?
    end

    # Returns true if the syllable's length feature has the value
    # long.
    def long?
      @length.long?
    end

    # Returns true if the syllable's length feature has the value
    # short.
    def short?
      @length.short?
    end

    # Returns true is the stress feature is unset.
    def stress_unset?
      @stress.unset?
    end

    # Returns true is the length feature is unset.
    def length_unset?
      @length.unset?
    end

    # Sets the syllable's length feature to the value long.
    def set_long
      @length.set_long
      self # returning self allows chaining method calls
    end

    # Sets the syllable's length feature to the value short.
    def set_short
      @length.set_short
      self
    end

    # Sets the syllable's stress feature to the value main_stress.
    def set_main_stress
      @stress.set_main_stress
      self
    end

    # Sets the syllable's stress feature to the value unstressed.
    def set_unstressed
      @stress.set_unstressed
      self
    end

    # Set the morpheme that this syllable is affiliated with to _morph_.
    def set_morpheme(morph)
      @morpheme = morph
      self
    end

    # Returns a string representation of the syllable, consisting of two
    # characters.
    #
    # The first character denotes the stress feature:
    # * unstressed [s]
    # * main stress [S]
    # * unset [?]
    #
    # The second character denotes the length feature:
    # * short [.]
    # * long [:]
    # * unset [?]
    #
    # Thus, an unstressed long syllable would be represented "s:", while
    # a short syllable with an unset stress feature would be represented
    # "?.".
    def to_s
      "#{stress_to_s}#{length_to_s}"
    end

    # Returns a single character string representation of the syllable's
    # stress feature.
    def stress_to_s
      return 'S' if main_stress?
      return 's' if unstressed?
      return '?' if stress_unset?

      'stress_not_defined'
    end
    private :stress_to_s

    # Returns a single character string representation of the syllable's
    # length feature.
    def length_to_s
      return '.' if short?
      return ':' if long?
      return '?' if length_unset?

      'length_not_defined'
    end
    private :length_to_s

    # Constructs a string representation of the syllable suitable for use
    # with GraphViz (for constructing lattice diagrams). Differs from
    # #to_s() in three ways:
    # * It uses a prefix consonant to indicate the morpheme type:
    #   "p" for root, "k" for suffix, "t" for prefix, in keeping with the
    #   paka world.
    # * It uses an accented a instead of S for a stressed vowel, and
    #   an unaccented a instead of s for an unstressed vowel.
    # * It uses no symbol to represent short vowel length instead of ".".
    def to_gv
      "#{morpheme_to_gv}#{stress_to_gv}#{length_to_gv}"
    end

    # Returns a single character string representation of the morpheme
    # type of the morpheme containing this syllable. The character
    # is of a type used for putting PAKA style string output suitable
    # for use with GraphViz.
    def morpheme_to_gv
      return 'p' if morpheme.root?
      return 'k' if morpheme.suffix?
      return 't' if morpheme.prefix?

      'morpheme_type_not_defined'
    end
    private :morpheme_to_gv

    # Returns a string representation of the syllable's stress feature.
    # The string is suitable for use in graph diagrams generated with
    # GraphViz.
    def stress_to_gv
      return 'á' if main_stress?
      return 'a' if unstressed?
      return '?' if stress_unset?

      'stress_type_not_defined'
    end
    private :stress_to_gv

    # Returns a string representation of the syllable's length feature.
    # The string is suitable for use in graph diagrams generated with
    # GraphViz.
    def length_to_gv
      return '' if short?
      return ':' if long?
      return '?' if length_unset?

      'length_type_not_defined'
    end
    private :length_to_gv

    # Iterator over the features of the syllable.
    def each_feature # :yields: feature
      yield @length
      yield @stress
    end

    # Returns the syllable's _type_ feature. Raises an exception if the
    # syllable does not have a feature of type _type_.
    def get_feature(type)
      each_feature { |f| return f if f.type == type }
      # No feature of that type was found; raise a RuntimeError.
      msg1 = 'Syllable#get_feature():'
      msg2 = "parameter #{type} is not a valid feature type."
      raise "#{msg1} #{msg2}"
    end

    # Sets the _feature_type_ feature of the syllable to _feature_value_.
    # Returns a reference to the syllable's feature.
    #
    # Raises a RuntimeError if _feature_type_ is invalid.
    #
    # Raises a RuntimeError if _feature_value_ is invalid.
    def set_feature(feature_type, feature_value)
      syl_feat = get_feature(feature_type) # can raise invalid type error
      # raise an exception if invalid value
      msg1 = 'SL::Syllable#set_feature invalid feature value parameter:'
      msg = "#{msg1} #{feature_value}"
      raise msg unless syl_feat.valid_value?(feature_value) || \
                       (feature_value == Feature::UNSET)

      syl_feat.value = feature_value
      syl_feat
    end
  end
end
