# Scraper in Ruby

article: https://itnext.io/building-a-basic-scraper-with-ruby-1cec071ada83

captures an established search items (make and model) from the url: https://www.dupontregistry.com/
the search items are passed during debugging `binding.pry`

```
# run
ruby scraper.rb

# passing search items
bentley = Scraper.new("bentley", "continental gt")
bentley.scrape

```
