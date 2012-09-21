module Beds
  module CLI
    class Scaffold
      def initialize(options)
        @options = {
          :viewdir => "./views",
          :public => "public",
          :controllers => "./controllers",
          :routefile => "./scaffold.rb",
          :list => true,
          :save => true,
          :template => true,
          :new => true,
          :index => true,
          :run_hooks => true,
          :exclude => []
        }; @options[:assets] = "#{@options[:public]}/assets"
        get_options(options)
        load_models
        make_files
        run_hooks if @options[:run_hooks]
      end
      private
      # Run post-scaffold hooks
      def run_hooks
        #begin 
          @scaffold.templates[:hooks].each {|key,hook| puts "Running hook: #{key}"; instance_eval(hook) }
        #rescue Exception => e
        #  puts "Error running hook #{e.message}"
        #end
      end
      ## Load model data from data mapper
      def load_models
        begin
          load "#{@options[:app]}"
        rescue Exception => e
          puts "Unable to load models. #{e.message}"
          exit 1
        end
        @scaffold = Beds::Scaffold.new(@options)
        @scaffold.generate
      end
      
      ## Write the generated files to disk.
      def make_files
        @gen_files = []
        [@options[:viewdir],@options[:public],@options[:assets],@options[:controllers]].each {|directory| Dir.mkdir(directory) unless File.directory?(directory) }
        @scaffold.routes.each do |controller,contents|
          if File.exist?(File.join(@options[:controllers],"#{controller}.rb")) and @options[:force] != true then
            puts "Error: Controller #{File.join(@options[:controllers],"#{controller}.rb")} already exists. Not writing"
          else
            File.open(File.join(@options[:controllers],"#{controller}.rb"),"w") {|file| file.write(contents) }
            @gen_files << File.join(@options[:controllers],"#{controller}.rb")
          end
        end
      
        @scaffold.views.each {|file,content|
          if File.exist?(File.join(@options[:viewdir],file)) and ! @options[:force] then
            puts "Warning: file #{File.join(@options[:viewdir],file)} exists. Not overwriting"
          else
            @gen_files << File.join(@options[:viewdir],file)
            File.open(File.join(@options[:viewdir],file),"w") {|file| file.write(content) }
          end
        }

        puts "Generated files: #{@gen_files.join(", ")}"
      end
      ## Get optoins from CLI input
      def get_options(options)
        optparser = OptionParser.new do |opts|
          opts.banner = " Usage: #{File.basename($0)} scaffold -m <models.rb> [OPTIONS]"
            opts.on("-m","--models FILE", "Specify file with DataMapper models defined.") do |app|
              @options[:app] = app
            end
            opts.on("-v","--viewdir","Specify which directory to place the views in. Default: ./views/") do |viewdir|
              @options[:viewdir] = viewdir
            end
            opts.on("-r","--routefile", "Sepcify the file to generate the routes in. Default: scaffold.rb") do |routefile|
              @options[:routefile] = routefile
            end
            opts.on("--exclude x,y,z", Array, "Do not generate anything for specified models, or before, index, and/or layout") do |models|
              @options[:exclude] = models
            end
            opts.on("--only x,y,z", Array, "Only process the specified models.") do |models|
              @options[:only] = models
            end
            opts.on("-f","--[no-]force", "Overwtie files") do |force|
              @options[:force] = force
            end
            opts.on("--[no-]hooks", "Run hooks") do |hooks|
              @options[:run_hooks] = hooks
            end
        end
        begin
          optparser.parse! options
          raise OptionParser::InvalidOption, "[NONE]" if @options[:app].nil?
        rescue OptionParser::InvalidOption => e
          puts e
          puts optparser
          exit 1
        end
      end
    end
  end
end
