# frozen_string_literal: true

# Author: Bruce Tesar
#
# This is an acceptance test for the typology generation for SL.
# It tests the output created by bin/generate_typology_1r1s.rb.

require_relative '../../lib/odl/resolver'
require 'otlearn/language_learning_runner'

RSpec.describe 'Generating the 1r1s typology for SL', :acceptance do
  before(:context) do
    project_dir = ODL::PROJECT_DIR
    @sl_fixture_dir = File.join(project_dir, 'test', 'fixtures', 'sl')
    @generated_dir = File.join(project_dir, 'data', 'sl')
    Dir.mkdir(@generated_dir) unless Dir.exist?(@generated_dir)
    # The executable dir must be a relative path, otherwise a bunch of
    # warnings are generated about redefining constants when the load
    # command is executed. Maybe the paths fed to the require statements
    # look different with an absolute path, and require fails to recognize
    # that a file has already been required?
    executable_dir = File.join('bin', 'sl')
    load "#{executable_dir}/generate_typology_1r1s.rb"
  end

  before do
    fname = 'outputs_typology_1r1s.mar'
    @fixture_file = File.join(@sl_fixture_dir, fname)
    @generated_file = File.join(@generated_dir, fname)
    @fixture_value = []
    OTLearn::LanguageLearningRunner.read_languages(@fixture_file) \
        { |label, outputs| @fixture_value << [label, outputs] }
    @generated_value = []
    OTLearn::LanguageLearningRunner.read_languages(@generated_file) \
        { |label, outputs| @generated_value << [label, outputs] }
  end

  it 'produces output that matches its test fixture' do
    expect(@generated_value).to eq @fixture_value
  end
end
