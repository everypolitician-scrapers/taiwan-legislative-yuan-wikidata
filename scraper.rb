#!/bin/env ruby
# encoding: utf-8

require 'wikidata/fetcher'

names_8 = WikiData::Category.new( 'Category:第8屆中華民國立法委員', 'zh').member_titles
names_9 = WikiData::Category.new( 'Category:第9屆中華民國立法委員', 'zh').member_titles

EveryPolitician::Wikidata.scrape_wikidata(names: { zh: names_8 | names_9 }, output: false)

