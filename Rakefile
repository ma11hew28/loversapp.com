desc "Convert markdown files to erb"
task :build do
  require 'rdiscount'
  %w(faq privacy).each do |f|
    file = File.new(File.join("views", "#{f}.erb"), "w") # "w" truncates file
    file.puts RDiscount.new(File.read(File.join("views", "#{f}.md"))).to_html
  end
end

desc "Update heroku branch from master"
task :commit do
  system("git co master
  git br -D heroku
  git co -b heroku
  git cherry-pick lovers_yml
  git push staging heroku:master -f")
end
