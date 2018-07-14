
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
  s.summary = 'time tools for flor'

  s.description = %{
Time tools for flor and the floraison project. Cron parsing and occurrence computing. Timestamps and more.
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'README.{md,txt}',
    'CHANGELOG.{md,txt}', 'CREDITS.{md,txt}', 'LICENSE.{md,txt}',
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  #s.add_runtime_dependency 'tzinfo'
  s.add_runtime_dependency 'raabro', '~> 1.1'
  s.add_runtime_dependency 'et-orbi', '~> 1.1', '>= 1.1.3'

  s.add_development_dependency 'rspec', '~> 3.7'

  s.require_path = 'lib'
end

