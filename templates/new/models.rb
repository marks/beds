require 'rubygems'
require 'dm-core'
require 'dm-mysql-adapter'
require 'dm-migrations'
require 'dm-validations'

DataMapper.setup(:default, "mysql://localhost/<%=@app%>")

## Include Models Below.
## Example:
#class User
#  include DataMapper::Resource
#   property :id, Serial
#   property  :name, String, :required => true, :messages => { :presence => "Please enter your name" }
#   property  :login, String, :required => true, :unique => true, :messages => { :presence => "Please select a login ID", :is_unique => "Login already in use. Try again" }
#   property  :pasword, String, :required => true, :length => 6..100, :messages => { :presence => "Please provide a password", :length => "Sorry.  Your password must be between 6 and 100 characters long." }
#   property  :email, String, :format => :email_address, :unique => true, :messages => {  :format => "Please check your email address and try again.", :presence => "It looks like you forgot to enter your email address.", :is_unique => "Sorry. This email is already associated with a different account" }
#   property  :level , Integer, :required => true
#   property  :account_id, Integer, :required => true
#end

