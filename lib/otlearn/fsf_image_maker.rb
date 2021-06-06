# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'

module OTLearn
  # An image maker that constructs a 2-dimensional sheet representation
  # of a Fewest Set Features learning step.
  class FsfImageMaker
    # Returns a new image maker for Fewest Set Features.
    # :call-seq:
    #   FsfImageMaker.new -> image_maker
    #--
    # _sheet_class_ is a dependency injection used for testing.
    def initialize(sheet_class: nil)
      @sheet_class = sheet_class || Sheet
    end

    # Returns a sheet containing the image of the FSF learning step.
    # :call-seq:
    #   get_image(fsf_step) -> sheet
    def get_image(fsf_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Fewest Set Features'
      # indicate if the grammar was changed
      sheet[2, 1] = "Grammar Changed: #{fsf_step.changed?.to_s.upcase}"
      add_failed_winner_info(fsf_step, sheet)
      add_candidate_info(fsf_step, sheet)
      sheet
    end

    # Adds info about the failed winner to the sheet
    def add_failed_winner_info(step, sheet)
      failed_winner = step.failed_winner
      subsheet = @sheet_class.new
      if failed_winner.nil?
        subsheet[1, 2] = 'No failed winner set a feature.'
      else
        subsheet[1, 2] = 'Failed Winner'
        subsheet[1, 3] = failed_winner.morphword.to_s
        subsheet[1, 4] = failed_winner.input.to_s
        subsheet[1, 5] = failed_winner.output.to_s
      end
      sheet.append(subsheet)
    end
    private :add_failed_winner_info

    # Adds
    # Returns nil.
    def add_candidate_info(step, sheet)
      candidates = step.success_instances
      return nil if candidates.empty?

      subsheet = @sheet_class.new
      candidates.each_with_index do |cand, idx|
        subsheet[1, 2] = 'Successful Features'
        subsheet[2 + idx, 3] = cand.winner.morphword.to_s
        subsheet[2 + idx, 4] = cand.winner.input.to_s
        subsheet[2 + idx, 5] = cand.winner.output.to_s
      end
      sheet.append(subsheet)
      nil
    end
    private :add_candidate_info
  end
end
