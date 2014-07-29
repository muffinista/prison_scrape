#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "rubygems"
require "bundler/setup"

require 'open-uri'
require 'nokogiri'

span = 1..1820
span.each { |x| 
  puts x
  if File.exist?("data/#{x}.html")
    f = File.open("data/#{x}.html")
    doc = Nokogiri::HTML(f)
    f.close

    skip = false
    
    doc.search('//ul').each do |node| 
      node.remove
    end
    
    h1 = doc.css("h1").first
    puts h1.text

    root = nil
    data = {}
    data['Name'] = h1.text.strip

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

        if value == "None."
          value = 0
        end
        
        data[root][key] = value
        puts "#{root} -- #{key} #{value}"
      end
    end
  end
} # span.each
