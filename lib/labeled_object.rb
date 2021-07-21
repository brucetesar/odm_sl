# frozen_string_literal: true

# Author: Bruce Tesar

# This class follows the Decorator pattern, and attaches a label attribute
# to the base object provided to the constructor. Missing methods are
# delegated to the base object. A duplicate of the object contains a
# duplicate of the base object and of the label.
class LabeledObject
  # The label attached to the base object.
  attr_accessor :label

  # External access to the base object; used for testing.
  attr_reader :base_obj # :nodoc:

  # Returns a new labeled object. The label is initialized to the empty
  # string.
  # :call-seq:
  #   new(base_obj) -> labeled_obj
  def initialize(base_obj)
    @base_obj = base_obj
    @label = ''
  end

  # Returns a string consisting of the label followed by the #to_s
  # of the base object.
  # :call-seq:
  #   to_s -> str
  def to_s
    "#{label} #{base_obj}"
  end

  # Returns a duplicate object. The duplicate contains a duplicate of the
  # base object, and a duplicate of the label.
  # :call-seq:
  #   dup -> labeled_obj
  def dup
    copy = LabeledObject.new(@base_obj.dup)
    copy.label = label.dup
    copy
  end

  # Delegate all method calls not explicitly defined here to the
  # base object.
  def method_missing(name, *args, &block) # :nodoc:
    if @base_obj.respond_to?(name)
      @base_obj.send(name, *args, &block)
    else
      super
    end
  end

  # Indicates that the object responds to those methods that are
  # successfully delegated to the base object.
  def respond_to_missing?(name, include_private = false) # :nodoc:
    @base_obj.respond_to?(name) || super
  end
end
