# frozen_string_literal: true

# Author: Bruce Tesar
#
# This acceptance spec runs learning on all 24 SL languages,
# and checks the generated learning outputs against the test fixtures.

require_relative '../../lib/odl/resolver'

require 'otlearn/language_learning_factory'
require 'otlearn/language_learning_runner'
require 'sl/system'

RSpec.describe 'Running ODL on SL', :acceptance do
  before(:context) do
    # Set up directory paths
    data_dir = File.join(ODL::DATA_DIR, 'sl')
    data_file = File.join(data_dir, 'outputs_typology_1r1s.mar')
    @expected_dir =
      File.join(ODL::PROJECT_DIR, 'test', 'fixtures', 'sl_learning')
    @generated_dir = File.join(ODL::TEMP_DIR, 'sl_learning')
    # Configure and build the learner
    factory = OTLearn::LanguageLearningFactory.new
    factory.para_mark_low.learn_consistent.test_consistent
    factory.system = SL::System.instance
    learner = factory.build
    # Run learning on all of the languages
    runner = OTLearn::LanguageLearningRunner.new(factory.system, learner)
    runner.prep_output_dir(@generated_dir, '*.csv')
    runner.run_languages(data_file) do |label, outputs|
      result = runner.run(label, outputs)
      runner.write(result, @generated_dir)
    end
  end

  (1..24).each do |num|
    context "on language L#{num}" do
      before(:example) do
        # Read each file's contents into a string
        @generated = IO.read "#{@generated_dir}/LgL#{num}.csv"
        @expected = IO.read "#{@expected_dir}/LgL#{num}.csv"
      end
      it 'produces output that matches its test fixture' do
        expect(@generated).to eq @expected
      end
    end
  end
end
