# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb'].exclude('test/integration/**')
end

default_tasks = %i[test]

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  default_tasks << :rubocop
rescue LoadError # rubocop:disable Lint/SuppressedException
end

task default: default_tasks
