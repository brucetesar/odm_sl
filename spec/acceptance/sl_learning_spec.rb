# frozen_string_literal: true

# Author: Bruce Tesar
#
# This acceptance spec runs learning on all 24 SL languages,
# and verifies that learning was successful for all languages.

require_relative '../../lib/odl/resolver'
require 'otlearn/language_learning_factory'
require 'otlearn/language_learning_runner'
require 'sl/system'

RSpec.describe OTLearn::LanguageLearningRunner, :acceptance do
  data_file = File.join(ODL::SPEC_DIR, 'fixtures', 'sl',
                        'outputs_typology_1r1s.mar')

  before do
    # Configure and build the learner
    factory = OTLearn::LanguageLearningFactory.new
    factory.para_mark_low.learn_consistent.test_consistent
    factory.system = SL::System.instance
    learner = factory.build
    # Create the learning runner
    @runner = described_class.new(factory.system, learner)
  end

  described_class.read_languages(data_file) do |label, outputs|
    it "sucessfully learns #{label}" do
      @result = @runner.run(label, outputs)
      expect(@result).to be_learning_successful
    end
  end
end
