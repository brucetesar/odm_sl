# frozen_string_literal: true

# Author: Bruce Tesar

# This acceptance spec runs learning on all 24 SL languages,
# and verifies that learning was successful for all languages.

require_relative '../../lib/odl/resolver'
require 'otlearn/language_learning_factory'
require 'otlearn/language_learning_runner'
require 'sl/system'
require 'psych'

RSpec.describe OTLearn::LanguageLearningRunner, :acceptance do
  context 'when run on the outputs of the SL languages' do
    # Configure the learner factory
    factory = OTLearn::LanguageLearningFactory.new
    factory.para_mark_low.learn_consistent.test_consistent
    factory.system = SL::System.instance

    # Create a new learner and runner for each language to be learned.
    # This avoids any possibility of cross-test interaction.
    before do
      # Build the learner
      learner = factory.build
      # Create the learning runner
      @runner = described_class.new(factory.system, learner)
    end

    # For each language in SL, read the fixture outputs, run learning on
    # the outputs, and verify that learning is successful.
    data_file = File.join(ODL::SPEC_DIR, 'fixtures', 'sl',
                          'outputs_typology_1r1s.yml')
    fixture_data = Psych.load_file(data_file)
    fixture_data.each do |fix_lang|
      label, outputs = fix_lang
      it "sucessfully learns #{label}" do
        result = @runner.run(label, outputs)
        expect(result).to be_learning_successful
      end
    end
  end
end
