prison_scrape
=============

This is some simple code to scrape data on US prisons from [insideprison.com](http://insideprison.com). It's being used to power the [@USPrisons](https://twitter.com/usprisons) twitter bot. 

USAGE
=====

Run scrape.rb and scrape-county.rb to download the raw HTML data. The scripts will sleep between each page download, please don't abuse someone else's servers!

Once that is done, run parse-all.rb to turn the data into a JSON array. The format should be relatively obvious, but please contact me with any questions.


LICENSE
=======

Since the source data is licensed as [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/deed.en_US), so is the data here, and the code to generate it. The only real changes are converting from HTML to JSON, and making some of the numeric data a little cleaner to read. Any thanks for the existence of the data should go to [insideprison.com](http://insideprison.com).

