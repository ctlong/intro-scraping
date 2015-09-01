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

  def scrape_one_company(annual_income_statement,company)
    if annual_income_statement.any?

      new_income_statement = company.annual_incomes.new

      AnnualIncome.columns[3..52].each_with_index do |column,index|
        if annual_income_statement[index].text != '-'
          new_income_statement["#{column.name}"] = annual_income_statement[index].text.gsub(",",'')
        else
          new_income_statement["#{column.name}"] = nil
        end
      end
      new_income_statement.save
    end
  end

  desc "Scrape from Google Finance"
  task :google_finance => :environment do
    require "open-uri"
    require "nokogiri"

    companies = Company.all

    companies.each do |company|
      url = "https://www.google.com/finance?q=NASDAQ:#{company.symbol}&fstype=ii"
      url_data = open(url).read #.read
      html_doc = Nokogiri::HTML(url_data)
      [2,3,4,5].each do |num|
        specific_format = "#incannualdiv tr > *:nth-child(#{num})"
        annual_income_statement = html_doc.css(specific_format)
        scrape_one_company(annual_income_statement,company)
      end
    end
  end

  desc "countries of great soccer players"
  task :add_countries => :environment do
    require "open-uri"
    require "nokogiri"

    url = "https://en.wikipedia.org/wiki/FIFA_100"
    url_data = open(url).read
    html_doc = Nokogiri::HTML(url_data)
    specific_format = "tr > td > h2 > span > a"
    list_of_countries = html_doc.css(specific_format)
    list_of_countries.each do |country|
      Country.create(name: country.text)
    end
  end

  desc "List of great soccer players"
  task :add_players => :environment do
    require "open-uri"
    require "nokogiri"

    url = "https://en.wikipedia.org/wiki/FIFA_100"
    url_data = open(url).read
    html_doc = Nokogiri::HTML(url_data)
    countries = Country.all
    country_format = "table table"
    country_players = html_doc.css(country_format)
    countries.each_with_index do |country,index|
      player_format = "tr td"
      players = country_players[index].css(player_format)
      info_list = ["name","position","dob"]
      new_player = country.players.new
      info_index = 0
      players.each do |player|
        if "#{info_list[info_index]}" == 'name'
          new_player["#{info_list[info_index]}"] = player.text.gsub('*','')
        else
          new_player["#{info_list[info_index]}"] = player.text
        end
        if "#{info_list[info_index]}" == 'dob'
          new_player.save
          new_player = country.players.new
        end
        if info_index < 2
          info_index += 1
        else
          info_index = 0
        end
      end
    end
  end
end