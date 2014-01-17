require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'

url = 'http://data.gov.uk/feeds/custom.atom?res_format=CSV'

atom = Nokogiri::XML(open(url))

link = atom.css('link[rel="last"]').last[:href]

pages = link.match(/page=([0-9]+)/)[1].to_i

csvs = []

pages.times do |i|
  url = "http://data.gov.uk/feeds/custom.atom?res_format=CSV&page=#{i + 1}"
  atom = Nokogiri::XML(open(url))
  entries = atom.css('entry')
  entries.each do |entry|
    csv = {}
    title = entry.css('title').last.text
    link = entry.css('link[rel="enclosure"]').last[:href]
    puts link
    ckan = JSON.parse(open(link).read)
    ckan['resources'].each do |resource|
      if resource['format'] == "CSV"
        csv = {}
        csv[:dataset] = title
        csv[:dataset_url] = link
        csv[:url] = resource['url']
        csv[:description] = resource['description']
        csv[:size] = resource['size']
        csv[:last_modified] = resource['last_modified']
        csvs << csv 
      end
    end
  end
end

CSV.open("csv_urls.csv", "w") do |csv|
  csv << csvs.first.keys
  csvs.each do |row|
    csv << row.values
  end
end