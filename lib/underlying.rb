# frozen_string_literal: true

# Author: Bruce Tesar

# An underlying form is the phonological representation associated with
# a morpheme, in the form of a list of correpondence elements.
#
# Underlying subclasses from Array, and so inherits a variety of methods.
class Underlying < Array
  # Returns an empty Underlying object.
  # :call-seq:
  #   new() -> underlying
  def initialize
    super
  end

  # Returns a deep copy duplicate of the underlying form, containing
  # a duplicate of each of the correspondence elements of the original.
  # :call-seq:
  #   dup() -> underlying
  def dup
    copy = Underlying.new
    each { |el| copy << el.dup }
    copy
  end

  # String form is the concatenation of the string form of each
  # element in the underlying form (with no separating symbols).
  # :call-seq:
  #   to_s() -> string
  def to_s
    join
  end
end
