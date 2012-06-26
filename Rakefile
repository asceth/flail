require "bundler"
Bundler.setup

require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

gemspec = eval(File.read(File.join(Dir.pwd, "flail.gemspec")))

task :build => "#{gemspec.full_name}.gem"

task :test => :spec
task :default => :spec

file "#{gemspec.full_name}.gem" => gemspec.files + ["flail.gemspec"] do
  system "gem build flail.gemspec"
  system "gem install flail-#{Flail::VERSION}.gem"
end

