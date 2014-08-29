#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "rubygems"
require "bundler/setup"

require 'open-uri'
require 'nokogiri'

require 'json'

output = {}
if File.exist?("data.json")
  output = JSON.parse( IO.read("data.json") )
end

puts output.keys.count

names = []

span = 1..2949
span.each { |x| 
  #puts x
  if File.exist?("data/county#{x}.html")
    f = File.open("data/county#{x}.html")
    doc = Nokogiri::HTML(f)
    f.close

    skip = false

    h1 = doc.css("h1").first
    #puts h1.text

    root = nil
    data = {}
    name = h1.text.strip
    data['Name'] = name

    guts = doc.css("table.table_main_content table table").first    
    guts.css("tr").each do |row|
      if row.to_s =~ /Regional Statistics/
        skip = true
      end

      key = row.css("td").first.text.strip
      value = row.css("td").last.text.strip

      if ["Facts", "Safety", "Staff", "Staff & Employment", "Services & Amenities"].include?(key)
        if key == "Staff & Employment"
          key = "Staff"
        end
        root = key
        next
      end
      
      if !skip
        data[root] ||= {}

        if value == "None."
          value = 0
        end

        key.gsub!(/^Jail /, "Facility ")
        key.gsub!(/^Facility Address/, "Address")        
        key.gsub!(/^Facility State/, "State")        
        key.gsub!(/^Facility Zip-code/, "Zip-code")

        if key == "Facility Name"
          value = value.gsub(/"/, "")
          value = value.split.map(&:capitalize).join(' ')
        end

        if value == "--"
          value = ""
        end
        
        data[root][key] = value
        #puts "#{root} -- #{key} #{value}"
      end
    end

#    puts data.inspect
    key = data["Facts"]["Facility Name"] + ": " + data["Facts"]["City"] + ", " + data["Facts"]["State"]
    if names.include?(key)
      puts key
    end
    names << key

    # need to add URL
    data["url"] = "http://www.insideprison.com/county_jails_details.asp?ID=#{x}"    
    output[key] = data
  end
} # span.each


File.open("data.json","w") do |f|
  x = JSON.pretty_generate output
  f.write(x)

#  f.write(output.to_json)
end
