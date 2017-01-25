# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "markov/version"

Gem::Specification.new do |s|
  s.name        = "markov"
  s.version     = Markov::VERSION
  s.authors     = ["Jay Tee"]
  s.email       = ["jaytee@jayteesf.com"]
  s.homepage    = ""
  s.summary     = %q{Markov Chain implementation}
  s.description = %q{Pass it a list of entries (words, letters, ???) then, give it an entry and query for a "next" entry - the most likely next or perhaps some random threshold based next-entry }

  s.rubyforge_project = "markov"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'

  # specify any dependencies here; for example:
  # s.add_runtime_dependency "rest-client"
end
