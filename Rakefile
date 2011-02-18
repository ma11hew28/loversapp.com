desc "Convert markdown files to erb"
task :build do
  require 'rdiscount'
  %w(faq privacy).each do |f|
    file = File.new(File.join("views", "#{f}.erb"), "w") # "w" truncates file
    file.puts RDiscount.new(File.read(File.join("views", "#{f}.md"))).to_html
  end
end
