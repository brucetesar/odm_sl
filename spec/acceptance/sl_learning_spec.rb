# frozen_string_literal: true

# Author: Bruce Tesar
#
# This acceptance spec runs learning on all 24 SL languages,
# and checks the generated learning outputs against the test fixtures.

require_relative '../../lib/odl/resolver'

require 'otlearn/language_learning_factory'
require 'sl/system'
require 'otlearn/language_learning_image_maker'
require 'grammar'
require 'csv_output'

def read_languages_from_file(data_file)
  File.open(data_file, 'rb') do |fin|
    until fin.eof
      label, outputs = Marshal.load(fin)
      yield label, outputs
    end
  end
end

RSpec.describe 'Running ODL on SL', :acceptance do
  before(:context) do
    data_dir = File.join(ODL::DATA_DIR, 'sl')
    @expected_dir =
      File.join(ODL::PROJECT_DIR, 'test', 'fixtures', 'sl_learning')
    @generated_dir = File.join(ODL::TEMP_DIR, 'sl_learning')
    if Dir.exist? @generated_dir
      csv_files = Dir.glob("#{@generated_dir}/*.csv")
      csv_files.each { |fn| File.delete(fn) }
    else
      Dir.mkdir @generated_dir
    end
    data_file = File.join(data_dir, 'outputs_typology_1r1s.mar')
    factory = OTLearn::LanguageLearningFactory.new
    factory.para_mark_low.learn_consistent.test_consistent
    factory.system = SL::System.instance
    lang_sim = factory.build
    image_maker = OTLearn::LanguageLearningImageMaker.new
    read_languages_from_file(data_file) do |label, outputs|
      grammar = Grammar.new(system: SL::System.instance)
      grammar.label = label
      result = lang_sim.learn(outputs, grammar)
      sim_image = image_maker.get_image(result)
      out_file = File.join(@generated_dir, "#{label}.csv")
      csv = CsvOutput.new(sim_image)
      csv.write_to_file(out_file)
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
