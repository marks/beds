Gem::Specification.new do |s|
  s.name    = 'beds'
  s.version = '0.0.1'
  s.summary = 'The BootStrap ERb DataMapper Sinatra [scaffolder]'
  s.executables = [ 'beds' ]
  s.default_executable = [ 'beds' ]
  s.author   = 'James Paterni'
  s.email    = 'james@ruby-code.com'
  s.homepage = 'http://ruby-code.com/projects/beds'

  # These dependencies are only for people who work on this gem
  s.add_development_dependency 'rspec'

  # Include everything in the lib folder
  s.files = Dir['lib/**/*']

  # Supress the warning about no rubyforge project
  s.rubyforge_project = 'nowarning'
end

