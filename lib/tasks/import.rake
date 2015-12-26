require 'rubygems'
require 'nokogiri'
require 'open-uri'


desc "Run task queue worker"
task import_movies: :environment do
  page = Nokogiri::HTML(open("http://www.azillionmonkeys.com/qed/imdbtop.html"))
  puts page.class # => Nokogiri::HTML::Document
  page.css('tr').each_with_index do |row, index|
    #page.css('tr')[0].children.each_with_index { |c,i | print  "#{i} - #{c.text}\n" }
    #row = page.css('tr')[2]
    if(index >50)
      break
    end
    begin
      link = row.children[3].children[0].attr("href").sub("bounce.html?", "")
      Item.create kind: 'Movie', title: row.children[5].text, rank: row.children[0].text, points: row.children[2].text, link: link, confidence: row.children[4].text
    rescue Exception => e
      print e.message
    end
  end
end
  task import_games: :environment do
    page = Nokogiri::HTML(open("/Users/jin/geek-cloud-datastore/db/snes.html"))
    page.css('table.chart').children.each_with_index do |row, index|
      if(index >50)
        break
      end
      begin
        Item.create kind: 'Game', title: row.children[3].text, rank: row.children[1].text, points: 100, confidence: (row.children[21].text.to_f * 1000000)
      rescue Exception => e
        print e.message
      end
    end

  end
