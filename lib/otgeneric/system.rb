# frozen_string_literal: true

# Author: Bruce Tesar

module OTGeneric
  # Linguistic system object when all candidates/competitions are
  # individually listed.
  class System
    # The constraints of the system.
    attr_reader :constraints

    # Returns a new OTGeneric::System object. The list of constraints
    # for the system is taken from the first candidate of the first
    # competition in the list.
    # competition_list - a list of the competitions of the system.
    # :call-seq:
    #   new(competition_list) -> system
    def initialize(competition_list)
      @comp_list = competition_list
      @constraints = @comp_list.first.first.constraint_list
    end

    # Returns the competition (array of candidates) for _input_.
    # :call-seq:
    #   gen(input) -> competition
    def gen(input)
      @comp_list.find { |comp| comp[0].input == input }
    end
  end
end
