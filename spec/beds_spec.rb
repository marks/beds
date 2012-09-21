require 'rubygems'
require "./lib/beds.rb"
require './lib/cli.rb'
require './lib/scaffold.rb'
require 'dm-core'


## Need some sort of db model for beds to work.  
class User
  include DataMapper::Resource
   property :id, Serial
   property  :name, Text
   property  :login, Text
   property  :pasword, Text
   property  :email, Text
   property  :level , Integer
   property  :account_id, Integer
end

describe Beds, "#Scaffold" do

  scaffold = Beds::Scaffold.new
  it "Can scaffold" do
    scaffold.generate.should == true
  end
  it "Generates views" do
    scaffold.views.keys.count.should > 0
  end
  it "Generates routes" do
    scaffold.routes.keys.count.should > 0
  end
  it "Loads the templates" do
    scaffold.templates.keys.count.should > 0
  end
end

