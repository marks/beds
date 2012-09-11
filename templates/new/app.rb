require 'sinatra'
require './models.rb'
Dir.glob("#{File.dirname(__FILE__)}/controllers/*.rb").each { |controller| load controller }

