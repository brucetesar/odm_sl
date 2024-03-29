# frozen_string_literal: true

# Author: Bruce Tesar

require 'grammar'
require 'csv_output'
require 'otlearn/language_learning_image_maker'

module OTLearn
  # This class provides methods useful for running a language learner.
  class LanguageLearningRunner
    # Returns a new runner for language learning.
    # :call-seq:
    #   new(system, learner) -> runner
    #--
    # The named parameters image_maker and csvout_class are dependency
    # injections used for testing.
    def initialize(system, learner, image_maker: nil, csvout_class: nil)
      @system = system
      @learner = learner
      @image_maker = image_maker || LanguageLearningImageMaker.new
      @csvout_class = csvout_class || CsvOutput
    end

    # Runs the language _learner_ (provided to the runner's constructor)
    # on _label_ and _outputs_.
    # Returns the learning result produced by _learner_.
    # :call-seq:
    #   run(label, outputs) -> result
    def run(label, outputs)
      grammar = Grammar.new(@system)
      grammar.label = label
      @learner.learn(outputs, grammar)
    end

    # Formats a learning _result_ as a CSV image, and writes
    # it to a .csv file.
    # * The named parameter _out_dir_ specifies a subdirectory to which
    #   the output file should be written. The default value is '.', the
    #   current working directory.
    # * The named parameter _filename_ is the name of the output file
    #   (the file extension will be .csv). The default value is the
    #   label of the grammar specified within _result_.
    # :call-seq:
    #   write(result) -> nil
    #   write(result, out_dir: mydir, filename: myfile) -> nil
    def write(result, out_dir: '.', filename: nil)
      label = if filename.nil?
                result.grammar.label
              else
                filename
              end
      sim_image = @image_maker.get_image(result)
      out_file = File.join(out_dir, "#{label}.csv")
      csv = @csvout_class.new(sim_image)
      csv.write_to_file(out_file)
      nil
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
