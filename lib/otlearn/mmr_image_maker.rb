# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'

module OTLearn
  # An image maker that constructs a 2-dimensional sheet representation
  # of a Max Mismatch Ranking learning step.
  class MmrImageMaker
    # Returns a new image maker for Max Mismatch Ranking.
    # :call-seq:
    #   MmrImageMaker.new -> image_maker
    #--
    # _sheet_class_ is a dependency injection used for testing.
    def initialize(sheet_class: nil)
      @sheet_class = sheet_class || Sheet
    end

    # Returns a sheet containing the image of the MMR learning step.
    # :call-seq:
    #   get_image(mmr_step) -> sheet
    def get_image(mmr_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Max Mismatch Ranking'
      # indicate if the grammar was changed
      sheet[2, 1] = "Grammar Changed: #{mmr_step.changed?.to_s.upcase}"
      add_failed_winner_info(mmr_step, sheet)
      add_all_failed_winners(mmr_step, sheet)
      sheet
    end

    # Adds info about the failed winner to the sheet
    def add_failed_winner_info(step, sheet)
      failed_winner = step.failed_winner
      subsheet = @sheet_class.new
      subsheet[1, 2] = 'Failed Winner'
      word_to_row(failed_winner, 1, subsheet)
      sheet.append(subsheet)
    end
    private :add_failed_winner_info

    def word_to_row(word, row, sheet)
      sheet[row, 3] = word.morphword.to_s
      sheet[row, 4] = word.input.to_s
      sheet[row, 5] = word.output.to_s
      sheet
    end
    private :word_to_row

    def add_all_failed_winners(step, sheet)
      subsheet = @sheet_class.new
      subsheet[1, 2] = 'All Failed Winners'
      step.failed_winner_list.each_with_index do |fw, idx|
        word_to_row(fw, 2 + idx, subsheet)
      end
      sheet.append(subsheet)
    end
    private :add_all_failed_winners
  end
end
