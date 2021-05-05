# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/grammar_test_image_maker'

module OTLearn
  # A 2-dimensional sheet representation of a SingleFormLearning object,
  # which contains a synopsis of a single form learning step.
  class SingleFormLearningImageMaker
    # Constructs a single form learning image from a single form learning
    # step.
    # :call-seq:
    #   new -> image_maker
    #--
    # grammar_test_image_maker and sheet_class are dependency injections
    # used for testing.
    def initialize(grammar_test_image_maker: nil, sheet_class: nil)
      @grammar_test_image_maker = grammar_test_image_maker || \
                                  GrammarTestImageMaker.new
      @sheet_class = sheet_class || Sheet
    end

    # Constructs the image from the single form learning step. Returns
    # a sheet containing the image of the single form learning step.
    # :call-seq:
    #   get_image(sf_step) -> sheet
    def get_image(sf_step)
      sheet = @sheet_class.new
      sheet[1, 1] = 'Single Form Learning'
      # Construct and add Grammar Test information
      test_image = @grammar_test_image_maker.get_image(sf_step.test_result)
      sheet.append(test_image)
      sheet
    end
  end
end
