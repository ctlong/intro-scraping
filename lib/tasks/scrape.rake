namespace :scrape do
  # this is a description of your task
  desc "Create all NASDAQ companies"
  # this is your task function
  task :create_companies => :environment do
    require "open-uri"
    require "csv"

    url = "http://s3.amazonaws.com/nvest/nasdaq_09_11_2014.csv"
    url_data = open(url) #open() is powered by open-uri
    #csv is just a string that seperates values by commas
    # CSV.foreach(url_data) do |symbol, name, last_sale, market_cap|
    #   Company.create(symbol: symbol,name: name,last_sale: last_sale,market_cap: market_cap)
    # end
    CSV.foreach(url_data,:headers => true) do |row|
      Company.create(symbol: row[0],name: row[1],last_sale: row[2],market_cap: row[3],adr_tso: row[4],ipo_year: row[5],sector: row[6],industry: row[7],summary_quote: row[8])
    end
  end
end