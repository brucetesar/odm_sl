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

    # Adds info about the failed winner to the sheet. Returns nil.
    def add_failed_winner_info(step, sheet)
      package = step.chosen_package
      return nil if package.nil?

      subsheet = @sheet_class.new
      failed_winner = package.word
      set_features = package.values
      subsheet[1, 2] = 'Chosen Feature'
      write_winner_features(failed_winner, set_features, subsheet, 2)
      sheet.append(subsheet)
      nil
    end
    private :add_failed_winner_info

    # Writes the elements of a _failed_winner_ and the associated
    # feature/value pairs to consecutive column cells within _row_ of
    # _subsheet_.
    # Returns nil.
    def write_winner_features(failed_winner, set_features, subsheet, row)
      col = 1
      subsheet[row, col += 1] = failed_winner.morphword.to_s
      subsheet[row, col += 1] = failed_winner.input.to_s
      subsheet[row, col += 1] = failed_winner.output.to_s
      set_features.each do |fv_pair|
        subsheet[row, col += 1] = fv_pair.feature_instance.morpheme.to_s
        subsheet[row, col += 1] = fv_pair.feature_instance.feature.type.to_s
        subsheet[row, col += 1] = fv_pair.alt_value.to_s
      end
      nil
    end
    private :write_winner_features

    # Adds information about the successful feature sets to the sheet.
    # Returns nil.
    def add_candidate_info(step, sheet)
      candidates = step.consistent_packages
      return nil if candidates.empty?

      subsheet = @sheet_class.new
      subsheet[1, 2] = 'Successful Features'
      candidates.each_with_index do |cand, idx|
        row = 2 + idx
        write_winner_features(cand.word, cand.values, subsheet, row)
      end
      sheet.append(subsheet)
      nil
    end
    private :add_candidate_info
  end
end
