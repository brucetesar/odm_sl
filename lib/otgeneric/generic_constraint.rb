# frozen_string_literal: true

# Author: Bruce Tesar

require 'constraint'

module OTGeneric
  # A constraint that contains only a name and a type. It does not have
  # any violation evaluation function. This is used for generic grammars
  # where the violations assess to candidates are spelled out directly
  # in the data provided, rather than calculated by the linguistic system.
  class GenericConstraint < Constraint
    # An inner class serving as the "content object" for generic
    # constraints. It packages the name and type into an object that can
    # be passed to the constructor for the superclass Constraint.
    class GContent # :nodoc:
      attr_reader :name, :type

      def initialize(name, type)
        @name = name
        @type = type
      end
    end

    # Returns a new generic constraint object.
    # === Parameters
    # * _name_ - the name of the constraint.
    # * _type_ - type of constraint; must be one of the type constants.
    #   * Constraint::FAITH    faithfulness constraint
    #   * Constraint::MARK     markedness constraint
    # :call-seq:
    #   new(name, type) -> constraint
    def initialize(name, type)
      content = GContent.new(name, type)
      super(name, type, content)
    end
  end
end
