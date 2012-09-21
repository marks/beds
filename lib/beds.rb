#!/usr/bin/env ruby
require 'erb'
require 'optparse'
## == Beds - BootStrap Erb DataMapper Sinatra [Scaffolder]
##
## * For general information on using Beds to scaffold your Sinatra projects please see README.rdoc
## * Or see Beds:Scaffold

module Beds
  ## Generates Scaffolds based off of DataMappr models.
	class Scaffold
    # Returns an array of generated routes
    attr_reader :routes
    # Returns an array of views and file names.
    attr_reader :views
    # Returns a hash containing file_name => file_contents key pairs.
    attr_reader :templates
    ## * opts should be a hash
    ## * Defautly loads data for all models.
    ##
    ## Valid Options:
    ##   :only - An array that only generates views for the specified models.
    ##   :exclude - An array containing models that should not be generatd. 
		def initialize(opts = {:exclude => [], :only => nil})
			@routes = {}
			@views = {}
			@models = []
			@opts = opts
			DataMapper::Model.descendants.entries.each {|entry|
        @models << entry
			}
			@models.delete_if { |model| @opts[:exclude].include? model.name or @opts[:exclude].include? model.name.downcase }
			@models.select! { |model| @opts[:only].include? model.name or @opts[:only].include? model.name.downcase } unless @opts[:only].nil?
      load_templates
		end
    ##  Generate views and routes for models.  Will genrate the *view* and *routes* attributes.
		def generate
			result = Hash.new
			routes = Hash.new
			@templates[:static_routes].each { |key,value| next if @opts[:exclude].include? key.to_s; puts "Processing Route: #{key}"; @routes['default'] ||= String.new ; @routes['default'] << ERB.new(value,nil,"<>").result(binding) } if @opts[:only].nil?
			@templates[:static_erb].each { |key,value| next if @opts[:exclude].include? key.to_s; puts "Processing Template: #{key}";@views["#{key.to_s}.erb"]=ERB.new(value,nil,"<>").result(binding) } if @opts[:only].nil?
			@models.each { |entry|
				@model_name = entry.inspect
				@properties = entry.properties
				puts "Processing Model: #{@model_name}"
				@templates[:routes].each {|key,value|
          @routes[entry.to_s.downcase] ||= String.new
					@routes[entry.to_s.downcase] << ERB.new(value,nil,"<>").result(binding) 
				}
				@templates[:erb].each { |key,value|
					@views["#{key.to_s}_#{@model_name.downcase}.erb"] = ERB.new(value,nil,"<>").result(binding)
				}
			}
			return true
		end
		private
    ## Called by .new, Locates and loads templaes into memory.
    def load_templates
      home_dir = "~/.beds"
      template_dir = "#{File.dirname(__FILE__)}/../templates"
      @templates=Hash.new
      @templates[:static_routes] = { }
      @templates[:static_erb] = { }
      @templates[:routes] = { }
      @templates[:erb] = { }
      @templates[:hooks] = { }
      @templates.each do |key,val|
        template_files = File.exist?("#{home_dir}/#{key.to_s}") ? Dir.glob("/#{home_dir}/#{key.to_s}/*") : Dir.glob("/#{template_dir}/#{key.to_s}/*")
        template_files.each { |file| @templates[key][File.basename(file).sub(/\.erb$/,"")] = File.open(file).read } 
      end
    end
    
    ## Determines the type of form to generate for DataMapper objects.
		def form_type(object,properties)
			append = String.new
			properties.each {|key,value|
				append << " #{key}='#{value}'"
			}

			case object
				when DataMapper::Property::Serial  # Serial #'s should be generated. Do not create a form for entry for it.
					""
				when DataMapper::Property::String
					"<input type='text' class='span2' #{append} />"
				when DataMapper::Property::Boolean
					"<input type='checkbox' #{append}/>"
				when DataMapper::Property::Text
					"<textbox class='span3' #{append - append[:value]}>#{append[:value] unless append[:value].nil?}</textbox>"
				when DataMapper::Property::Float, DataMapper::Property::Integer, DataMapper::Property::Decimal
					"<input type='text' class='span1' #{append} />"
				when DateTime, Date, Time
					"<input type='text' class='span2' #{append} />"
				else
					"<input type='text' class='span1' #{append} />"
			end
		end
	end
end
