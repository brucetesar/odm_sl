# frozen_string_literal: true

# Author: Bruce Tesar

require 'grammar'
require 'csv_output'

module OTLearn
  # This class provides methods useful for running a language learner.
  class LanguageLearningRunner
    # Returns a new runner for language learning.
    # :call-seq:
    #   new(system, learner, image_maker) -> runner
    def initialize(system, learner, image_maker)
      @system = system
      @learner = learner
      @image_maker = image_maker
    end

    # Runs the language _learner_ (provided to the runner's constructor)
    # on _label_ and _outputs_.
    # Returns the learning result produced by _learner_.
    # :call-seq:
    #   run(label, outputs) -> result
    def run(label, outputs)
      grammar = Grammar.new(system: @system)
      grammar.label = label
      @learner.learn(outputs,grammar)
    end

    # Reads all of the languages in _data_file_. For each language,
    # the label and outputs are fed to the program block.
    def run_languages(data_file)
      File.open(data_file, 'rb') do |fin|
        until fin.eof
          label, outputs = Marshal.load(fin)
          yield label, outputs
        end
      end
    end

    # Formats a learning _result_ as a CSV image, and writes
    # it to a .csv file in directory _out_dir_.
    def write(result, out_dir)
      label = result.grammar.label
      sim_image = @image_maker.get_image(result)
      out_file = File.join(out_dir, "#{label}.csv")
      csv = CsvOutput.new(sim_image)
      csv.write_to_file(out_file)
    end

    # Prepares a directory _dir_ for receiving output files.
    # If _dir_ does not currently exist, it is created.
    # All files in the directory that match _pattern_ are deleted.
    # _pattern_ is a glob pattern fed to Dir.glob().
    #
    # Example:
    #   runner.prep_output_dir('mydir', '*.csv')
    # This deletes all files of type .csv in mydir.
    def prep_output_dir(dir, pattern)
      Dir.mkdir dir unless Dir.exist? dir
      files = Dir.glob(File.join(dir, pattern))
      files.each { |fn| File.delete(fn) }
    end
  end
end
