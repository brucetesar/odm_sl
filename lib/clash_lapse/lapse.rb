# frozen_string_literal: true

# Author: Bruce Tesar

module ClashLapse
  # The markedness constraint Lapse assesses one violation for each pair
  # of adjacent unstressed syllables.
  class Lapse
    # The name of the constraint: Lapse.
    attr_reader :name

    # The the type of the constraint: MARK.
    attr_reader :type

    # Returns a Lapse object.
    # :call-seq:
    #   new -> constraint_content
    def initialize
      @name = 'Lapse'
      @type = Constraint::MARK
    end
  end
end
