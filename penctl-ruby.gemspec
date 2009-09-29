# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{penctl-ruby}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jannis Hermanns"]
  s.date = %q{2009-09-29}
  s.description = %q{With penctl-ruby you can add and remove servers to a pen server list and to change settings without the need to restart the pen balancer.}
  s.email = %q{jannis@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/pen_balancer.rb",
     "lib/penctl.rb",
     "penctl-ruby.gemspec",
     "rails/init.rb",
     "spec/lib/pen_balancer_spec.rb",
     "spec/lib/penctl_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/jayniz/penctl-ruby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Ruby implementation of penctl}
  s.test_files = [
    "spec/lib/pen_balancer_spec.rb",
     "spec/lib/penctl_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
