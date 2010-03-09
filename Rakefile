require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cumulus_csv"
    gem.summary = %Q{Helps you save uploaded csv files containing data to amazon s3, and gives you a way to download and loop through the data in a background process easily}
    gem.description = %Q{CSV Files: I hate them, you probably do too, but sometimes you need to get data into your system and this is the only way it's happening.  

    If you're deploying a rails app in a cloud setup, you may have troubles if you're trying to store an uploaded file locally and process it later in a background thread (I know I have).  

    cumulus_csv is one way to solve that problem.  You can save your file to your S3 account, and loop over the data inside it at your convenience later.  So it doesn't matter where you're doing the processing, you just need to have the key you used to store the file, and you can process away.}
    gem.email = "ethan.vizitei@gmail.com"
    gem.homepage = "http://github.com/evizitei/cumulus_csv"
    gem.authors = ["evizitei"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_development_dependency "mocha", ">= 0.9.8"
    gem.add_dependency "aws-s3", ">= 0.6.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cumulus_csv #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
