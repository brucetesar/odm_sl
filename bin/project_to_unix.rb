# frozen_string_literal: true

# Author: Bruce Tesar

# Write a parallel project directory in which all of the text
# files have been converted to unix-style format.
# DOS: CR+LF; nothing at end of file.
# Unix: LF; LF needed at end of file.

require_relative '../lib/odl/resolver'

require 'find'

# Takes the string _str_, converts it to the universal newline
# convention (regardless of what newline convention it originally was),
# and then converts it to the unix newline convention (LF only).
def string2unix(str)
  univ_str = str.encode(str.encoding, universal_newline: true)
  univ_str.encode(str.encoding, lf_newline: true)
end

# Define source and target project directories
SOURCE = ODL::PROJECT_DIR
target_relative_path = File.join(SOURCE, '../odm_sl_unix')
TARGET = File.expand_path(target_relative_path)

# Delete any existing directory tree at that path, and then
# (re)create the root directory for the tree.
FileUtils.rm_r TARGET if Dir.exist? TARGET
Dir.mkdir TARGET

# Traverse source tree
Find.find(SOURCE) do |path|
  Find.prune if File.basename(path) == '.git'
  Find.prune if File.basename(path) == '.idea'
  Find.prune if File.basename(path) == 'data'
  Find.prune if File.basename(path) == 'doc'
  Find.prune if File.basename(path) == 'features'
  Find.prune if File.basename(path) == 'spec'
  Find.prune if File.basename(path) == 'temp'
  Find.prune if File.basename(path) == 'test'
  Find.prune if File.basename(path) == 'tmp'
  Find.prune if File.basename(path) == '.gitignore'
  Find.prune if File.basename(path) == '.rspec'
  Find.prune if File.basename(path) == 'LICENSE'
  Find.prune if File.basename(path) == 'README'
  Find.prune if File.basename(path) == 'Rakefile'
  Find.prune if File.basename(path) =~ /[.]bat$/
  Find.prune if path =~ /bin\/main\.rb$/
  # Translate the path to the target
  target_path = path.gsub(SOURCE, TARGET)
  if File.directory?(path)
    # If a directory, a target counterpart should be created.
    Dir.mkdir(target_path) unless Dir.exist?(target_path)
  elsif File.file?(path)
    # If neither a directory nor a file, don't copy it.
    # Read the file in binary mode into an ASCII-8BIT string.
    content_string = IO.read(path, mode: 'rb')
    # Transcode the string into unix line terminator format.
    trans_string = string2unix(content_string)
    # Write the transcoded string to the target file.
    IO.write(target_path, trans_string, mode: 'wb')
  end
end
