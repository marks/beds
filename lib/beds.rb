  #!/usr/bin/env ruby
require 'erb'
require 'optparse'

class SinScaffold
  STATIC_ROUTE_TEMPLATES = {
    :before => %q^
      before do
        @active_page = request.path_info.split(/\//)[1]
        @active_page = "index" if @active_page.nil?
      end
    ^,
    :index => %Q^
    get '/' do
      erb :index
    end
  ^ }
  STATIC_ERB_TEMPLATES = {
      :layout => %Q^
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Application</title>
        <meta name="GeneratedBy" content="sdbscaffold"
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="">
        <meta name="author" content="">
        <!-- Le styles -->

        <link href="/assets/css/bootstrap.css" rel="stylesheet">
        <link href="/style.css" rel="stylesheet">
        <style>
          body {
            padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
          }
        </style>

        <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
          <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
        <script src="/assets/js/jquery.js" type="text/javascript"></script>
        <script>
          $(document).ready(function() {
            $("#<%%=@active_page%>").addClass("active");
          });
        </script>
        <!-- Le fav and touch icons -->
        <link rel="shortcut icon" href="/assets/ico/favicon.ico">
        <link rel="apple-touch-icon-precomposed" sizes="144x144" href="/assets/ico/apple-touch-icon-144-precomposed.png">
        <link rel="apple-touch-icon-precomposed" sizes="114x114" href="/assets/ico/apple-touch-icon-114-precomposed.png">
        <link rel="apple-touch-icon-precomposed" sizes="72x72" href="/assets/ico/apple-touch-icon-72-precomposed.png">
        <link rel="apple-touch-icon-precomposed" href="/assets/ico/apple-touch-icon-57-precomposed.png">
      </head>

      <body>

        <div class="navbar navbar-fixed-top">
          <div class="navbar-inner">
            <div class="container">
              <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </a>
              <a class="brand" href="#">YourApp</a>
              <div class="nav-collapse">
                <ul class="nav">
                  <li class="divider-vertical"></li>
                  <li id="index" ><a href="/">Home</a></li>
                  <% @models.each do |model| %>
                    <li id="<%=model.name.downcase%>" ><a href="/<%=model.name.downcase%>/"><%= model.name %></a></li>
                  <% end %>
                </ul>
                <ul class="nav pull-right">
                  <li class="divider-vertical"></li>
                  <li><a href="/login">Log<%%= session[:valid] ? "out" : "in"%></a></li>
                </ul>
              </div><!--/.nav-collapse -->
            </div>
          </div>
        </div>

        <div class="container">
          <%% if ! @flash.nil? then %>
            <span class="span9 offset1">
          <%% @flash.each do |alert| %>
            <div class="alert alert-<%%=alert[:level].downcase%>" style="margin:0px; margin-bottom:8px;">
              <button class="close" data-dismiss="alert">x</button>
              <strong><%%=alert[:level].capitalize%>!</strong> <%%=alert[:message]%>
              </div>
          <%% end %>
            </span>
          <%%end %>
            <%%= yield %>
        </div> <!-- /container -->

        <!-- Le javascript
        ================================================== -->
        <!-- Placed at the end of the document so the pages load faster -->
            <script src="/assets/js/bootstrap.min.js"></script>
      </body>
      </html>
    ^,
    :index => %Q^
      <div class="well">
        <div class="hero-unit">
        <h1>Models</h1>
          <p class="btn-group">
            <% @models.each do |model| %>
              <a class="btn btn-large btn-info" href="/<%=model.name.downcase%>/"><%= model.name %></a>
            <% end %>
          </p>
        </div>
      </div>
    ^
    }
  ROUTE_TEMPLATES = {
  :list => %Q^
    get '/<%=@model_name.downcase%>/?' do
      @offset = params["page"] if params["page"] =~ /[0-9]+/
      @offset ||= 0
      @db_objects = <%=@model_name%>.all(:limit => 20,:offset => @offset * 20)
      erb :list_<%=@model_name.downcase%>
    end
  ^,
  :new => %q^
    get '/<%=@model_name.downcase%>/new/?' do
      erb :new_<%=@model_name.downcase%>
    end
  ^,
  :save => %q^
    post '/<%=@model_name.downcase%>/save/?' do
      db_object = <%=@model_name%>.new
      params.each do |key,value|
        db_object.send("#{key}=",value) if <%=@model_name%>.properties.collect{|x| x.name}.include? key.to_sym
      end
      if db_object.save then
        redirect "/<%=@model_name.downcase%>/#{db_object.id}"
      else
        result = []
        db_object.errors.each do |e|
          result << "<li>#{e}</li>"
        end
        return "<UL>#{result.join("")}</UL>"
      end
    end
  ^,
  :edit => %q^
    get '/<%=@model_name.downcase%>/:id/?' do |id|
      pass if "#{id.to_i}" != "#{id}"
      @db_object = <%=@model_name%>.first(:id => id)
      return 404 if @db_object.nil?
      erb :edit_<%=@model_name.downcase%>
    end

    post '/<%=@model_name.downcase%>/:id/?' do |id|
      db_object = <%=@model_name%>.first(:id => id)
      redirect 404 if ! db_object
      params.each do |key,value|
        db_object.send("#{key}=",value) if <%=@model_name%>.properties.collect{|x| x.name}.include? key.to_sym
      end
      if db_object.save then
        redirect "/<%=@model_name.downcase%>/#{db_object.id}"
      else
        result = []
        db_object.errors.each do |e|
          STDERR.puts e
          result << "<li>#{e}</li>"
        end
        return "<UL>#{result.join("")}</UL>"
      end
    end
  ^,
  :delete => %q^
    get '/<%=@model_name.downcase%>/delete/:id/?' do |id|
      db_object = <%=@model_name%>.first(:id => id)
      if db_object then
        db_object.destroy
        redirect '/<%=@model_name.downcase%>/'
      else
        redirect 404
      end
    end
  ^
  }
  ERB_TEMPLATES = {
    :list => %Q^
      <a href="/<%=@model_name.downcase%>/new" class="btn btn-info">New</a>
      <table class="table table-bordered">
        <thead>
          <% @properties.each do |header| %>
            <th><%=header.name%></th>
          <% end %>
          <th>Actions</th>
        </thead>
        <tbody>
          <%% @db_objects.each do |object| %>
            <tr>
            <% @properties.each do |prop| %>
              <td><%%=object.<%=prop.name%>%></td>
            <%end%>
            <td><a href="/<%=@model_name.downcase%>/<%%=object.id%>" class="btn btn-mini">Edit</a>
            <a href="/<%=@model_name.downcase%>/delete/<%%=object.id%>" class="btn btn-mini">Delete</a></td>
            </tr>
          <%%end%>
        </tbody>
      </table>
    ^,
    :new => %q^
      <form class="well row" method="post" action="/<%=@model_name.downcase%>/save">
      <% @properties.each do |prop| %>
      <% next if prop.name == :id %>
        <label><%=prop.name.to_s%></label>
        <%=form_type(prop,:name => prop.name)%>

      <% end %>
        <button type="submit" class="btn">Submit</button>
      </form>
    ^,
    :edit => %q^
      <form class="well" method="post" action="/<%=@model_name.downcase%>/<%%= @db_object.id%>">
      <% @properties.each do |prop| %>
      <% next if prop.name == :id %>
        <label><%=prop.name.to_s%></label>
        <%=form_type(prop,:name => prop.name,:value => "<%= @db_object.#{prop.name} %%>")%>

      <% end %>
        <button type="submit" class="btn">Submit</button>
      </form>
    ^
  }

  def initialize(opts)
    @routes = []
    @views = {}
    @models = []
    @opts = opts
    DataMapper::Model.descendants.entries.each {|entry|
    @models << entry
    #@model_name=entry.inspect
    #@properties=entry.properties

    #puts ERB.new(ERB_TEMPLATES[:new]).result(binding)
    }
    @models.delete_if { |model| @opts[:exclude].include? model.name or @opts[:exclude].include? model.name.downcase }
    @models.select! { |model| @opts[:only].include? model.name or @opts[:only].include? model.name.downcase } unless @opts[:only].nil?
  end
  def generate
    result = Hash.new
    routes = Hash.new
    STATIC_ROUTE_TEMPLATES.each { |key,value| next if @opts[:exclude].include? key.to_s; puts "Processing Route: #{key}"; @routes << ERB.new(value,nil,"<>").result(binding) } if @opts[:only].nil?
    STATIC_ERB_TEMPLATES.each { |key,value| next if @opts[:exclude].include? key.to_s; puts "Processing Template: #{key}";@views["#{key.to_s}.erb"]=ERB.new(value,nil,"<>").result(binding) } if @opts[:only].nil?
    @models.each { |entry|
      @model_name = entry.inspect
      @properties = entry.properties
      puts "Processing Model: #{@model_name}"
      ROUTE_TEMPLATES.each {|key,value|
        @routes << ERB.new(value,nil,"<>").result(binding)
      }
      ERB_TEMPLATES.each { |key,value|
        @views["#{key.to_s}_#{@model_name.downcase}.erb"] = ERB.new(value,nil,"<>").result(binding)
      }
    }
    return true
  end
  def routes
    @routes
  end
  def views
    @views
  end
  private
  def form_type(object,properties)
    append = String.new
    properties.each {|key,value|
      append << " #{key}='#{value}'"
    }

    case object
      when DataMapper::Property::Serial
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
