namespace :scrape do
  # this is a description of your task
  desc "Create all NASDAQ companies"
  # this is your task function
  task :create_companies => :environment do
    puts "Hello World"
  end
end