# frozen_string_literal: true

# Author: Bruce Tesar

require 'rake'
require 'rake/clean'
require 'rubygems/package_task'
require 'rdoc/task'
require 'cucumber/rake/task'
require 'launchy'

desc 'delete all files/directories in the temp dir'
task :clear_temp do
  Dir.glob('temp/*').each do |f|
    rm_rf(f, verbose: false)
  end
end

# ***********
# RSpec Tasks
# ***********

require 'rspec/core/rake_task'

desc '' # undocumented, so won't appear in default raketask list
RSpec::Core::RakeTask.new(:spec_unit) do |t|
  t.rspec_opts = '--tag ~acceptance'
end

desc 'run RSpec unit specs (not acceptance)'
task spec: [:clear_temp, :spec_unit]

desc '' # undocumented, so won't appear in default raketask list
RSpec::Core::RakeTask.new(:spec_acceptance_tests) do |t|
  t.rspec_opts = '--tag acceptance'
end

desc 'run RSpec acceptance specs'
task spec_acceptance: [:clear_temp, :spec_acceptance_tests]

desc 'run RSpec wip specs'
RSpec::Core::RakeTask.new(:spec_wip_tests) do |t|
  t.rspec_opts = '--tag wip'
end

desc 'diff the learning of all 24 SL languages (acceptance specs)'
task :spec_diff_sl do
  kdiff3 = 'C:/Programs/kdiff3/kdiff3.exe'
  sl_fixture_dir = 'test/fixtures/sl_learning'
  generated_dir = 'temp/sl_learning'
  system "#{kdiff3} #{sl_fixture_dir} #{generated_dir}"
end

desc 'run RSpec specs with HTML output'
RSpec::Core::RakeTask.new(:spec_html) do |t|
  t.rspec_opts = '-f html -o spec/reports/rspec_report.html'
end

desc 'display all RSpec specs in a browser'
task spec_in_browser: [:spec_html] do
  # Display the rspec report in the system's default browser.
  Launchy.open('spec/reports/rspec_report.html')
end

# *************
# RuboCop Tasks
# *************

require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rspec'
end

# **************
# Cucumber Tasks
# **************

Cucumber::Rake::Task.new(:cucumber_text, 'Run Cucumber with text output') do |t|
  t.cucumber_opts = '-f progress'
end

Cucumber::Rake::Task.new(:cucumber_html, 'Generate cucumber HTML') do |t|
  t.cucumber_opts = '-f html -o features/reports/cucumber_report.html'
end

desc 'display cucumber in browser'
task cucumber_in_browser: [:cucumber_html] do
  # Display the cucumber report in the system's default browser.
  Launchy.open('features/reports/cucumber_report.html')
end

# **********
# RDoc Tasks
# **********

Rake::RDocTask.new do |rdoc|
  files = ['README', 'LICENSE', 'lib/**/*.rb', 'bin/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = 'README' # page to start on
  rdoc.title = 'odm_sl Docs'
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

desc 'display RDoc in browser'
task :rdoc_in_browser do
  # Display the rdoc documentation in the system's default browser.
  Launchy.open('doc/rdoc/index.html')
end

desc 'Regenerate RDoc and display in browser'
task rerdoc_in_browser: [:rerdoc] do
  # Display the rdoc documentation in the system's default browser.
  Launchy.open('doc/rdoc/index.html')
end

# *********
# Packaging
# *********

spec = Gem::Specification.new do |s|
  s.name = 'odm_sl'
  s.version = '0.0.1'
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Your summary here'
  s.description = s.summary
  s.author = ''
  s.email = ''
  # s.executables = ['your_executable_here']
  s.files = %w[LICENSE README Rakefile] + Dir.glob('{bin,lib,spec}/**/*')
  s.require_path = 'lib'
  s.bindir = 'bin'
end

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end
