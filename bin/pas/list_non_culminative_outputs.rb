# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar
#
# Scan through all the grammatical outputs of all the languages of the
# typology, and write to a text file all of the outputs that are not
# culminative.

# The resolver adds <project>/lib to the $LOAD_PATH.
require_relative '../../lib/odl/resolver'

# Requires for classes needed in loading data.
require 'pas/system'
require 'labeled_object'
require 'psych'

# Set up filenames and paths
data_dir = File.expand_path('pas', ODL::DATA_DIR)
data_file = File.join(data_dir, 'outputs_typology_1r1s.yml')
rpt_file = File.join(data_dir, 'non_culminative_outputs.txt')

# List the non-culminative outputs
output_data = Psych.load_file(data_file)
File.open(rpt_file, 'w') do |fout|
  output_data.each do |lang|
    lang.each do |o|
      fout.puts "#{lang.label} #{o.morphword} #{o}" unless o.main_stress?
    end
  end
end
