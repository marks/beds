module Beds
  module CLI
    class New
      attr_accessor :options, :gems, :app,:opts

      def initialize(opts)
        @options = { :configru => true, :bundler => true, :git => true, :db => :dm,:view => 'erb' }
        @gems=[]
        parse_args(opts)
        (STDERR.puts("Directory #{@app} already exists"); exit 1) if Dir.exist?("./#{@app}")
        init_dirs
        write_files
      end
      private
      def parse_args(options)
        @app ||= ""
        opts = OptionParser.new
        opts.banner = "Usage: #{__FILE__} [options] -a <app_name>"
        opts.on('-a', '--app [app]') {|app| @app=app}
        opts.on('-h', '--help', 'Display this information') { puts opts; exit }
        opts.on('-g', '--include-gem GEM', 'Require gem in gemfile') {|gem| @gems << gem}
        opts.on_tail("-h", "--help", "Display this information") { puts opts ; exit }
        begin
          (puts opts; exit 1) if options.empty? 
          opts.parse! options
        rescue OptionParser::InvalidArgument
          opts.warn "Invalid Argument: #{$!}"
          exit 1
        end
        return opts
      end
      def init_dirs
        Dir.mkdir("./#{@app}")
        Dir.chdir("./#{@app}")
        Dir.mkdir("./tmp")
        Dir.mkdir("./views")
        Dir.mkdir("./public")
        Dir.mkdir('./controllers')
      end

      def write_files
        template_dir = "#{File.dirname(__FILE__)}/../templates/new"
        template_files = Dir.exist?("~/.beds/new") ? Dir.glob("~/.beds/new/*") : Dir.glob("/#{template_dir}/*")
        template_files.each do |file| 
          File.open(File.basename(file).sub(/\.erb$/,""),"w") { |output| 
            output.write(ERB.new(File.open(file).read,nil,"<>").result(binding))
          }
        end
      end
    end
  end
end
