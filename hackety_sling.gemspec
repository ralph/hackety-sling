# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'sinatra/hackety_sling/version'

Gem::Specification.new do |s|
  s.name        = 'hackety_sling'
  s.version     = Sinatra::HacketySling::VERSION
  s.authors     = ['Ralph von der Heyden']
  s.email       = ['ralph@rvdh.de']
  s.homepage    = 'http://rvdh.de'
  s.summary     = %q{A simple blog engine based on Sinatra and document_mapper}
  s.description = %q{A simple blog engine based on Sinatra and document_mapper}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.add_dependency 'document_mapper'
  s.add_dependency 'erubis'
  s.add_dependency 'sinatra'
  s.add_dependency 'ratom'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'RedCloth'
end
