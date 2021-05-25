# frozen_string_literal: true

# Author: Bruce Tesar
#
# Generates the entire topology for the SL system with
# monosyllabic morphemes and root+suffix words (1r1s).

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/odl/resolver'

require 'sl/system'
require 'factorial_typology'
require 'psych'

# Generate the language typology data:
# a list of sets of language data, one for each language in
# the typology of the SL system, with each root and each suffix
# consisting of a single syllable (1r1s).
system = SL::System.instance
competition_list = system.generate_competitions_1r1s
ft_result = FactorialTypology.new(competition_list)

# Set the SL data directory.
data_dir = File.expand_path('sl', ODL::DATA_DIR)
# If the directory doesn't already exist, create it.
Dir.mkdir(data_dir) unless Dir.exist?(data_dir)
lang_dir = File.expand_path('lang', data_dir)
Dir.mkdir(lang_dir) unless Dir.exist?(lang_dir)

# Write human-readable files listing the winners for each of the languages
# of the typology.
ft_result.winner_lists.each do |lang|
  rpt_file = File.join(lang_dir, "#{lang.label}.txt")
  File.open(rpt_file, 'w') do |f|
    lang.each { |w| f.puts w.to_s }
  end
end

# Write the learning data for each language of the typology to a data file.
# Uses Psych to write an object to file in YAML format.
yml_file = File.join(data_dir, 'outputs_typology_1r1s.yml')
File.open(yml_file, 'w') do |f|
  Psych.dump(ft_result.learning_data, f)
end
