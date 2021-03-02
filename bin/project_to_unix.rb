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
Dir.mkdir TARGET unless Dir.exist? TARGET

# Delete any existing files in the target directory tree.
Find.find(TARGET) do |path|
  File.delete path if File.file?(path)
end

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
  # Translate the path to the target
  target_path = path.gsub(SOURCE, TARGET)
  if File.directory?(path)
    # If a directory, a target counterpart exists.
    Dir.mkdir(target_path) unless Dir.exist?(target_path)
  else
    # If the path is not a directory, then it must be a file.
    # Read the file in binary mode into an ASCII-8BIT string.
    content_string = IO.read(path, mode: 'rb')
    # Transcode the string into unix line terminator format.
    trans_string = string2unix(content_string)
    # Write the transcoded string to the target directory.
    IO.write(target_path, trans_string, mode: 'wb')
  end
end
