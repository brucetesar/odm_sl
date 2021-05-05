# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'pas/stress'
require 'pas/length'

module PAS
  # A syllable for the PAS system has two features, stress and length. It also
  # can have an affiliated morpheme.
  #
  # Learning algorithms are expected to use the "generic" interface, consisting
  # of the methods #each_feature() and #get_feature(). The method #each_feature()
  # is an iterator that yields each feature of the syllable in turn,
  # allowing other routines to work with syllables without knowing in advance
  # how many or what types of features they have.
  class Syllable
    # Returns the morpheme that this syllable is affiliated with.
    attr_reader :morpheme

    # Returns a syllable, initialized to the parameters if provided. Otherwise,
    # returns a syllable with unset features, and an empty string for the
    # morpheme.
    # :call-seq:
    #   new -> syllable
    def initialize
      @stress = Stress.new
      @length = Length.new
      @morpheme = '' # label of the morpheme this syllable is affiliated with.
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

    # Set the morpheme that this syllable is affiliated with to _m_.
    def set_morpheme(m)
      @morpheme = m
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
    # a short syllable with an unset stress feature would be represented "?.".
    def to_s
      stress_s = if main_stress? then 'S'
                 elsif unstressed? then 's'
                 elsif stress_unset? then '?'
                 else 'stress_nodef'
                 end
      length_s = if short? then '.'
                 elsif long? then ':'
                 elsif length_unset? then '?'
                 else 'length_nodef'
                 end
      "#{stress_s}#{length_s}"
    end

    # Constructs a string representation of the syllable suitable for use
    # with GraphViz (for constructing lattice diagrams). Differs from #to_s()
    # in three ways:
    # * It uses a prefix consonant to indicate the morpheme type:
    #   "p" for root, "k" for suffix, "t" for prefix, in keeping with the
    #   paka world.
    # * It uses an accented a [á] instead of S for a stressed vowel, and
    #   an unaccented a instead of s for an unstressed vowel.
    # * It uses no symbol to represent short vowel length instead of ".".
    def to_gv
      base = if morpheme.root? then 'p'
             elsif morpheme.suffix? then 'k'
             elsif morpheme.prefix? then 't'
             else 'morpheme_type_not_defined'
             end
      stress_s = if main_stress? then 'á'
                 elsif unstressed? then 'a'
                 elsif stress_unset? then '?'
                 else 'stress_type_not_defined'
                 end
      length_s = if short? then ''
                 elsif long? then ':'
                 elsif length_unset? then '?'
                 else 'length_type_not_defined'
                 end
      "#{base}#{stress_s}#{length_s}"
    end

    # Iterator over the features of the syllable.
    def each_feature # :yields: feature
      yield @length
      yield @stress
    end

    # Returns the syllable's _type_ feature. Raises an exception if the
    # syllable does not have a feature of type _type_.
    def get_feature(type)
      each_feature { |f| return f if f.type == type }
      raise "PAS::Syllable#get_feature(): parameter #{type}" \
            ' is not a valid feature type.'
    end

    # Sets the _feature_type_ feature of the syllable to _feature_value_.
    # Returns a reference to the syllable's feature.
    # Raises an exception if _feature_value_ is not a valid value.
    def set_feature(feature_type, feature_value)
      syl_feat = get_feature(feature_type)
      # raise an exception if invalid value
      unless syl_feat.valid_value?(feature_value) || \
             feature_value == Feature::UNSET
        msg = 'PAS::Syllable#set_feature invalid feature value' \
              " parameter: #{feature_value}"
        raise msg
      end
      syl_feat.value = feature_value
      syl_feat
    end
  end
end
