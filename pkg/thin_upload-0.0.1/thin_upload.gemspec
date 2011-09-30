# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thin_upload}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Dombi Attila}]
  s.date = %q{2011-09-30}
  s.description = %q{thin_upload provides upload progress measuring functionality for thin ruby server, progresses can be accessed via rack middleware.}
  s.email = %q{dombesz.attila@gmail.com}
  s.extra_rdoc_files = [%q{README.rdoc}, %q{lib/thin_upload.rb}, %q{lib/thin_upload/parser.rb}]
  s.files = [%q{Gemfile}, %q{Gemfile.lock}, %q{Manifest}, %q{README.rdoc}, %q{Rakefile}, %q{lib/thin_upload.rb}, %q{lib/thin_upload/parser.rb}, %q{test/test_helper.rb}, %q{test/thin_upload/parser_test.rb}, %q{thin_upload.gemspec}]
  s.homepage = %q{https://github.com/dombesz/thin_upload}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Thin_upload}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{thin_upload}
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{Upload progress meter for thin ruby server.}
  s.test_files = [%q{test/test_helper.rb}, %q{test/thin_upload/parser_test.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
