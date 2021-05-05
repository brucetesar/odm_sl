# frozen_string_literal: true

# Author: Bruce Tesar

require 'sheet'
require 'otlearn/otlearn'
require 'otlearn/phonotactic_learning_image_maker'
require 'otlearn/single_form_learning_image_maker'
require 'otlearn/contrast_pair_learning_image_maker'
require 'otlearn/induction_learning_image_maker'
require 'otlearn/error_image_maker'
require 'otlearn/language_learning'

module OTLearn
  # A 2-dimensional sheet representation of a LanguageLearning object,
  # which contains a synopsis of a language learning simulation.
  class LanguageLearningImageMaker
    # Constructs a language learning image from a language learning object.
    # :call-seq:
    #   LanguageLearningImageMaker.new -> image_maker
    #--
    # sheet_class is a dependency injection used for testing.
    def initialize(sheet_class: nil)
      @sheet_class = sheet_class || Sheet
      # Create a hash of image makers, one for each learning
      # step type. An image maker creates a sheet with an image
      # of information specific to the type of learning step.
      @image_makers = {}
      # The step type constants are defined in OTLearn.
      @image_makers[PHONOTACTIC] = PhonotacticLearningImageMaker.new
      @image_makers[SINGLE_FORM] = SingleFormLearningImageMaker.new
      @image_makers[CONTRAST_PAIR] = ContrastPairLearningImageMaker.new
      @image_makers[INDUCTION] = InductionLearningImageMaker.new
      @image_makers[ERROR] = ErrorImageMaker.new
    end

    # Set (change or add) the image maker object for _step_type_.
    def set_image_maker(step_type, maker)
      @image_makers[step_type] = maker
    end

    # Returns a sheet containing the image of the learning simulation.
    # :call-seq:
    #   get_image(language_learning) -> sheet
    def get_image(language_learning)
      sheet = @sheet_class.new
      # Put the language label first
      sheet[1, 1] = language_learning.grammar.label
      # Indicate if learning succeeded.
      sheet[2, 1] = "Learned: #{language_learning.learning_successful?}"
      # Add each step result to the sheet
      language_learning.step_list.each do |step|
        step_image = construct_step_image(step)
        sheet.add_empty_row
        sheet.append(step_image)
      end
      sheet
    end

    # Construct the image for a learning step.
    def construct_step_image(step)
      step_type = step.step_type
      unless @image_makers.key?(step_type)
        raise "LanguageLearningImageMaker: unrecognized step type #{step_type}"
      end

      @image_makers[step_type].get_image(step)
    end
    private :construct_step_image
  end
end
