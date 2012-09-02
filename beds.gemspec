Gem::Specification.new do |s|
  s.name    = 'beds'
  s.version = '0.1.0'
  s.summary = 'The BootStrap ERb DataMapper Sinatra [scaffolder]'
  s.description = 'Easily create Sinatra applications quikcly and easily by scaffolding your models.'
  s.author = 'James Paterni'
  s.executables = [ 'beds' ]
  s.default_executable = [ 'beds' ]
  s.author   = 'James Paterni'
  s.email    = 'james@ruby-code.com'
  s.homepage = 'http://ruby-code.com/projects/beds'
  
  s.requirements << 'sinatra, version 1.3.3'
  s.requirements << 'rubyzip, version 0.9.9'
  
  s.add_dependency('sinatra', ">= 1.3.3")
  s.add_dependency('rubyzip', ">= 0.9.9")
  # These dependencies are only for people who work on this gem
  s.add_development_dependency 'rspec'

  # Include everything in the lib folder
  s.files = Dir['lib/**/*']
  s.files = Dir['templates/**/*']
  # Supress the warning about no rubyforge project
  s.rubyforge_project = 'nowarning'
end

