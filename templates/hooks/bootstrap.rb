require 'open-uri'
require 'zip/zip'
require 'fileutils'
BOOTSTRAP_ZIP_URL="http://twitter.github.com/bootstrap/assets/bootstrap.zip"

File.open("bootstrap.zip","w") {|file| file.write(open(BOOTSTRAP_ZIP_URL).read) }
Zip::ZipFile.open('bootstrap.zip') { |zip_file|
 zip_file.each { |f|
   f_path=File.join("#{@options[:public]}/assets", f.name)
   FileUtils.mkdir_p(File.dirname(f_path))
   zip_file.extract(f, f_path) unless File.exist?(f_path)
 }
}
File.delete("bootstrap.zip")
