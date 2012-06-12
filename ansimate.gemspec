# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ansimate/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Enric Lluelles"]
  gem.email         = ["enric@lluell.es"]
  gem.description   = %q{Command line utility to transform ANSI console output to html}
  gem.summary       = %q{Command line utility to transform ANSI console output to html}
  gem.homepage      = "https://github.com/enriclluelles/ansimate"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ansimate"
  gem.require_paths = ["lib"]
  gem.version       = Ansimate::VERSION
end
