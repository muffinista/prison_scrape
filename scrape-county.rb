#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "rubygems"
require "bundler/setup"

require 'open-uri'
require 'nokogiri'

span = 1..2949
span.each { |x| 
  puts x
  #next if x.to_i == 577
  if ! File.exist?("data/county#{x}.html")
    begin
      url = "http://www.insideprison.com/county_jails_details.asp?ID=#{x}"
      puts url
      wikitext = open(url) do |f|
        f.read
      end
      puts wikitext
      File.open("data/county#{x}.html", 'w') {|f| f.write(wikitext) }
    rescue
      nil
    end
    sleep 2
  end
} # span.each
