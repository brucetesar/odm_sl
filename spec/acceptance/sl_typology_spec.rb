# frozen_string_literal: true

# Author: Bruce Tesar

# This is an acceptance test for the typology generation for SL.

require 'otlearn/language_learning_runner'
require 'sl/system'
require 'factorial_typology'
require 'sync_enum'

RSpec.describe 'FactorialTypology', :acceptance do
  context 'when generating the typology for SL 1r1s' do
    # Generate the typology data
    system = SL::System.instance
    competition_list = system.generate_competitions_1r1s
    ft_result = FactorialTypology.new(competition_list)
    lang_list = ft_result.factorial_typology
    generated_data = lang_list.map do |lang|
      outputs = OTLearn::LanguageLearningRunner.wlp_to_learning_data(lang)
      [lang.label, outputs]
    end
    # Retrieve the fixture data
    fixture_file = File.join('spec', 'fixtures', 'sl',
                             'outputs_typology_1r1s.mar')
    fixture_data = []
    OTLearn::LanguageLearningRunner.read_languages(fixture_file) \
      { |label, outputs| fixture_data << [label, outputs] }

    it 'generates the correct number of languages for SL 1r1s' do
      expect(generated_data.size).to eq fixture_data.size
    end

    iter = SyncEnum.new(generated_data.to_enum, fixture_data.to_enum)
    loop do
      gen_lang, fix_lang = iter.next
      it "generates a language with the label #{fix_lang[0]}" do
        expect(gen_lang[0]).to eq fix_lang[0]
      end

      it "generates the outputs for language #{fix_lang[0]}" do
        expect(gen_lang[1]).to eq fix_lang[1]
      end
    end
  end
end
