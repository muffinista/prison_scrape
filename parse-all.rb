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

def clean_key(key)
  key.gsub!(/^Jail /, "Facility ")
  key.gsub!(/^Facility Address/, "Address")        
  key.gsub!(/^Facility State/, "State")        
  key.gsub!(/^Facility Zip-code/, "Zip-code")

  key
end

def clean_value(key, value)
  if value == "None."
    value = "0"
  end
        
  if key == "Facility Name" || key == "City" || key == "State"
    value = value.gsub(/"/, "")
    value = value.split.map(&:capitalize).join(' ')
  end

  if key == "Inmates on Death Row"
    value = value.gsub(/[^0-9]/, "")
  end
  
  if value == "--"
    value = ""
  end

  # turn numeric strings into integers

  if value.gsub(/[^0-9,]/, "") == ""
    value = value.gsub(/,/, "")
  end
  if value.gsub(/[^0-9,$]/, "") == ""
    value = value.gsub(/,/, "")
  end
  
  value
end

def key_from_data(data)
  data["Facts"]["Facility Name"] + ": " + data["Facts"]["City"] + ", " + data["Facts"]["State"]
end

span = 1..2949
span.each { |x| 
  if File.exist?("data/county#{x}.html")
    f = File.open("data/county#{x}.html")
    doc = Nokogiri::HTML(f)
    f.close

    skip = false

    h1 = doc.css("h1").first

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

        key = clean_key(key)
        value = clean_value(key, value)

        if key == "Year Constructed" && value =~ /cost/
          year, cost = value.split(/ | /, 2)
          cost = cost.gsub(/[^0-9]/, "")

          value = year
          data[root]["Cost"] = cost
          #"1989 (at cost of $2,500,000)"
        end       
        
        data[root][key] = value
      end
    end

    key = key_from_data(data)

    # need to add URL
    data["url"] = "http://www.insideprison.com/county_jails_details.asp?ID=#{x}"    

    output[key] = data
  end
} # span.each

span = 1..1820
span.each { |x| 
  if File.exist?("data/#{x}.html")
    f = File.open("data/#{x}.html")
    doc = Nokogiri::HTML(f)
    f.close

    skip = false
    
    doc.search('//ul').each do |node| 
      node.remove
    end
    
    h1 = doc.css("h1").first

    root = nil
    data = {}
    name =  h1.text.strip
    data['Name'] = name
    
    guts = doc.css("table.table_main_content table table").first    
    guts.css("tr").each do |row|
      if row.to_s =~ /Regional Statistics/
        skip = true
      end

      key = row.css("td").first.text.strip
      value = row.css("td").last.text.strip

      if ["Facts", "Safety", "Staff", "Services & Amenities"].include?(key)
        root = key
        next
      end
      
      if !skip
        data[root] ||= {}

        key = clean_key(key)
        value = clean_value(key, value)       

        #puts "#{key} #{value}"
        
        if key == "Year Constructed" && value =~ /cost/
          year, cost = value.split(/ | /, 2)
          cost = cost.gsub(/[^0-9]/, "")

          puts year
          puts cost
          value = year
          data[root]["Cost"] = cost
          #"1989 (at cost of $2,500,000)"
        end       

        data[root][key] = value


      end
    end

    key = key_from_data(data)
    if names.include?(key)
      puts key
    end
    names << key

    data["url"] = "http://www.insideprison.com/state_federal_prison_details.asp?ID=#{x}"
    
    output[key] = data
    
  end
} # span.each



File.open("data.json","w") do |f|
  x = JSON.pretty_generate output.sort.to_h
  f.write(x)

#  f.write(output.to_json)
end
