# frozen_string_literal: true

# Author: Bruce Tesar

require 'morph_word'
require 'ui_correspondence'
require 'feature_instance'

# An ordered list of elements, and a correspondence relation between those
# elements and their correspondents in the lexicon. An input is typically
# formed by concatenating the underlying forms of the morphemes of
# a lexical word.
#
# Input subclasses from Array, and so inherits a variety of methods.
class Input < Array
  # the morphword associated with the input
  attr_accessor :morphword

  # the UI (underlying <-> input) correspondence
  attr_accessor :ui_corr

  # Creates a new input, with an empty element list and an empty UI
  # correspondence relation. If no morphword is provided as a parameter,
  # a new, empty instance of MorphWord is adopted.
  #
  # ==== Parameters
  # * _morphword_ - the morphological word associated with the input.
  #
  # :call-seq:
  #   Input.new() -> input
  #   Input.new(morphword: my_mword) -> input
  #--
  # _ui_corr_ and _feat_inst_class_ are dependency injections for testing.
  # _feat_inst_class_ is the class used to return feature instances
  # by the #each_feature() method.
  def initialize(morphword: MorphWord.new, ui_corr: UICorrespondence.new,
                 feat_inst_class: FeatureInstance)
    super()
    @morphword = morphword
    @ui_corr = ui_corr
    @feature_instance_class = feat_inst_class
  end

  # Returns a duplicate of the input. This is a deep copy, containing
  # a duplicate of the morphword and a duplicate of each input element.
  # The copy's UI correspondence is between the duplicate input elements
  # and the very same underlying elements of the lexicon.
  # :call-seq:
  #   dup() -> input
  def dup
    # Create an empty input for the copy. The morphword is set to nil in
    # the constructor call to avoid generation of a new Morphword object,
    # since the morphword field will be overwritten with a duplicate
    # of self's morphword.
    # The copy has an empty UI correspondence relation, which will have
    # pairs added to it that match the UI pairs of self.
    copy = Input.new(morphword: nil)
    copy.morphword = @morphword.dup
    # For each element of self, create a duplicate element and add it to
    # the copy. Then add a corresponding UI pair for the duplicate element,
    # if such a pair exists in self.
    each do |old_el|
      new_el = old_el.dup
      copy << new_el
      # Get the corresponding underlying element in self's UI
      # correspondence.
      under_el = @ui_corr.under_corr(old_el)
      # If a corresponding underlying element exists, add a correspondence
      # between the underlying element and the copy's input element.
      copy.ui_corr.add_corr(under_el, new_el) unless under_el.nil?
    end
    copy
  end

  # Returns true if self and other contain equivalent (==) elements.
  # Returns false otherwise.
  #
  # NOTE: does not check for equivalence of morphwords. To require that
  # as well, use Input#eql?().
  # :call-seq:
  #   input == other -> boolean
  def ==(other)
    return false unless size == other.size

    each_index { |idx| return false unless self[idx] == other[idx] }

    true
  end

  # Returns true of self and other contain equivalent (==) elements *and*
  # equivalent (==) morphwords.
  # The morphword equivalence requirement distinguishes Input#eql?() from
  # Input#==().
  # :call-seq:
  #   eql?(other) -> boolean
  def eql?(other)
    return false unless self == other

    return false unless morphword == other.morphword

    true
  end

  # Iterates through all feature instances of the input, yielding each
  # to the block. It progresses through the elements in order (in the
  # input), and each feature for a given element is yielded before
  # moving on to the next element. Returns a reference to self.
  # :call-seq:
  #   each_feature() { |feature_instance| ... } -> input
  def each_feature # :yields: feature_instance
    each do |element|
      element.each_feature do |feat|
        yield @feature_instance_class.new(element, feat)
      end
    end
    self
  end

  # Returns a string listing the elements of the input as a string,
  # with dashes between morphemes.
  # :call-seq:
  #   to_s() -> string
  def to_s
    morph = first.morpheme
    parts = []
    each do |syl|
      unless syl.morpheme == morph # a new morpheme has been reached
        parts << '-'
        morph = syl.morpheme
      end
      parts << syl.to_s
    end
    parts.join
  end

  # A string appropriate for GraphViz (no dashes between morphemes).
  # :call-seq:
  #   to_gv() -> string
  def to_gv
    parts = []
    each { |syl| parts << syl.to_gv }
    parts.join
  end
end
