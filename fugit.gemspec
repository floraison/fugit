
Gem::Specification.new do |s|

  s.name = 'fugit'

  s.version = File.read(
    File.expand_path('../lib/fugit.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux+flor@gmail.com' ]
  s.homepage = 'http://github.com/floraison/fugit'
  s.license = 'MIT'
  s.summary = 'time oriented utils for flor'

  s.description = %{
time oriented utilities for flor and the floraison project
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.md'
  ]

  #s.add_runtime_dependency 'tzinfo'
  s.add_runtime_dependency 'raabro', '>= 1.1.2'

  s.add_development_dependency 'rspec', '~> 3.4'

  s.require_path = 'lib'
end

