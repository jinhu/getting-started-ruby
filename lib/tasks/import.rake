require 'rubygems'
require 'nokogiri'
require 'open-uri'


desc "Run task queue worker"
task import_movies: :environment do
  page = Nokogiri::HTML(open("http://www.azillionmonkeys.com/qed/imdbtop.html"))
  puts page.class # => Nokogiri::HTML::Document
  page.css('tr').each do |row|
    #page.css('tr')[0].children.each_with_index { |c,i | print  "#{i} - #{c.text}\n" }
    #row = page.css('tr')[2]
    begin
      link = row.children[3].children[0].attr("href").sub("bounce.html?", "")
      Item.create kind: 'Movie', title: row.children[5].text, rank: row.children[0].text, points: row.children[1].text, link: link, confidence: row.children[4].text
    rescue Exception => e

    end
  end

end
