begin
  require 'psych'
rescue ::LoadError
end
require 'rubygems'
require 'rake'
require 'echoe'
require 'rake/testtask'


Echoe.new('thin_upload', '0.0.1.pre') do |p|
  p.summary                  = "Upload progress meter for thin ruby server."
  p.description              = "thin_upload provides upload progress measuring functionality for thin ruby server, progresses can be accessed via rack middleware."
  p.author                   = 'Dombi Attila'
  p.email                    = 'dombesz.attila-at-gmail.com'
  p.url                      = 'https://github.com/dombesz/thin_upload'
  p.ignore_pattern           = ["tmp/*", "script/*"]
  p.development_dependencies = ['thin']
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

Rake::TestTask.new do |t|
  t.libs << 'test'
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

desc "Run tests"
task :default => :test