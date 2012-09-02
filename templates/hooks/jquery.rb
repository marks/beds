require 'open-uri'
require 'fileutils'
JQUERY_URL="http://code.jquery.com/jquery-1.8.1.min.js"
f_path=File.join("#{@options[:public]}/assets/js")
FileUtils.mkdir_p(File.dirname(f_path))
File.open("#{f_path}/jquery.min.js") { |file| file.write(open(JQUERY_URL).read) }

