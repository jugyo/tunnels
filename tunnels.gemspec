# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tunnels/version"

Gem::Specification.new do |s|
  s.name        = "tunnels"
  s.version     = Tunnels::VERSION
  s.authors     = ["jugyo"]
  s.email       = ["jugyo.org@gmail.com"]
  s.homepage    = "https://github.com/jugyo/tunnels"
  s.summary     = %q{https --(--)--> http}
  s.description = %q{This tunnels https to http.}

  s.rubyforge_project = "tunnels"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "daemons"
  s.add_runtime_dependency "eventmachine"
end
