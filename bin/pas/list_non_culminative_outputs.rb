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
require 'psych'

# Set up filenames and paths
data_dir = File.expand_path('pas', ODL::DATA_DIR)
data_file = File.join(data_dir, 'outputs_typology_1r1s.yml')

out_dir = File.expand_path('pas', ODL::TEMP_DIR)
Dir.mkdir out_dir unless Dir.exist? out_dir
out_file = File.join(out_dir, 'non_culminative_outputs.txt')

# List the non-culminative outputs
output_data = Psych.load_file(data_file)
File.open(out_file, 'w') do |fout|
  output_data.each do |data|
    label, outputs = data
    outputs.each do |o|
      fout.puts "#{label} #{o.morphword} #{o}" unless o.main_stress?
    end
  end
end
