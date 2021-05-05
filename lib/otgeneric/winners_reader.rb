# frozen_string_literal: true

# Author: Bruce Tesar

module OTGeneric
  # Contains methods for converting a list of winners from an array
  # of strings for input and output to an array of candidate objects.
  # The candidate objects are retrieved from the externally supplied
  # attribute _competitions_.
  class WinnersReader
    # The list of competitions, each containing a list of candidates.
    attr_accessor :competitions

    # Returns a new WinnersReader object.
    # :call-seq:
    #   new -> reader
    def initialize
      @competitions = []
    end

    # For each pair of input/output strings in _data_,
    # the corresponding candidate is retrieved from the competitions
    # and added to the list of winners.
    # Returns an array of Candidate objects.
    def convert_array_to_winners(data)
      winner_list = []
      data.each do |row|
        comp = find_competition_for_input(row[0], @competitions)
        winner = find_candidate_for_output(row[1], comp)
        winner_list << winner
      end
      winner_list
    end

    # Find the competition corresponding to the _input_.
    # Return the found competition.
    # If _competitions_ does not contain a competition for _input_,
    # raise an exception.
    def find_competition_for_input(input, competitions)
      match_comp = competitions.find { |comp| comp[0].input == input }
      if match_comp.nil?
        msg =
          "Winner has input #{input}, but there is no such competition."
        raise msg
      end
      match_comp
    end
    private :find_competition_for_input

    # Find the candidate corresponding to the _output_.
    # Return the candidate.
    # If _competition_ does not contain a candidate for _output_,
    # raise an exception.
    def find_candidate_for_output(output, competition)
      winner = competition.find { |cand| cand.output == output }
      if winner.nil?
        msg =
          "Winner has input #{competition[0].input} output #{output}," \
          ' but there is no such candidate.'
        raise msg
      end
      winner
    end
    private :find_candidate_for_output
  end
end
