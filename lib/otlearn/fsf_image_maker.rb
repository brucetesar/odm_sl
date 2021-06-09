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
      unless fsf_step.chosen_package.nil?
        add_chosen_package_info(fsf_step.chosen_package, sheet)
        add_consistent_package_info(fsf_step.consistent_packages, sheet)
      end
      sheet
    end

    # Adds info about the failed winner to the sheet. Returns nil.
    def add_chosen_package_info(package, sheet)
      subsheet = @sheet_class.new
      winner = package.word
      features = package.values
      subsheet[1, 2] = 'Chosen Feature'
      write_winner_features(winner, features, subsheet, 2)
      sheet.append(subsheet)
      nil
    end
    private :add_chosen_package_info

    # Adds information about the consistent packages to the sheet.
    # Returns nil.
    def add_consistent_package_info(packages, sheet)
      subsheet = @sheet_class.new
      subsheet[1, 2] = 'Successful Features'
      packages.each_with_index do |cand, idx|
        row = 2 + idx
        write_winner_features(cand.word, cand.values, subsheet, row)
      end
      sheet.append(subsheet)
      nil
    end
    private :add_consistent_package_info

    # Writes the elements of the _winner_ and the associated _features_
    # (feature/value pairs) to consecutive column cells within _row_ of
    # _subsheet_.
    # Returns nil.
    def write_winner_features(winner, features, subsheet, row)
      col = 1 # the elements will begin in column 2.
      subsheet[row, col += 1] = winner.morphword.to_s
      subsheet[row, col += 1] = winner.input.to_s
      subsheet[row, col += 1] = winner.output.to_s
      features.each do |fv_pair|
        f_inst = fv_pair.feature_instance
        subsheet[row, col += 1] = f_inst.morpheme.to_s
        subsheet[row, col += 1] = f_inst.feature.type.to_s
        subsheet[row, col += 1] = fv_pair.alt_value.to_s
      end
      nil
    end
    private :write_winner_features
  end
end
