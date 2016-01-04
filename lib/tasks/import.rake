require 'rubygems'
require 'nokogiri'
require 'open-uri'


desc "Run task queue worker"

namespace :import do
  task movies: :environment do
    page = Nokogiri::HTML(open("http://www.azillionmonkeys.com/qed/imdbtop.html"))
    puts page.class # => Nokogiri::HTML::Document
    page.css('tr').each_with_index do |row, index|
      #page.css('tr')[0].children.each_with_index { |c,i | print  "#{i} - #{c.text}\n" }
      #row = page.css('tr')[2]
      if (index >50)
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
  task games: :environment  do
    print ENV['file']
    page = Nokogiri::HTML(open("/Users/jin/geek-cloud-datastore/public/#{ENV['file']}.html"))
    page.css('table.chart').children.each_with_index do |row, index|
    if index.odd?
      begin
        item = Item.create  kind: 'Game',
          rank: row.children[1].text,
          title: row.children[3].text,
          platform: row.children[5].text,
          year: row.children[7].text,
          genre: row.children[9].text,
          publisher: row.children[11].text,
          confidence: (row.children[21].text.to_f * 1000000)

        print "#{index}: - #{item.title}\n"
      rescue Exception => e
        print "#{index}: - #{e.message}\n"
      end
    end
  end

end

end