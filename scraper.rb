#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'wikidata/fetcher'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'rest-client'
require 'wikidata/fetcher'

def noko_for(url)
  Nokogiri::HTML(open(URI.escape(URI.unescape(url))).read) 
end

def wikinames8(url)
  noko = noko_for(url)
  colname = '姓名'
  noko.xpath('//table[.//tr[1]//td[contains(.,"%s")]]' % colname).map do |table|
    title = table.xpath('preceding-sibling::h2').last.text
    wantcol = table.xpath('.//tr[1]//td').find_index { |td| td.text == colname }
    names = table.xpath('.//tr/td[%d]//a[not(@class="new")]/@title' % (wantcol+1)).map(&:text)
    puts "#{title}: #{names.count}"
    names
  end.flatten(1)
end

def wikinames9(url)
  noko = noko_for(url)
  colname = '姓名'
  noko.xpath('//table[.//tr[1]//th[contains(.,"%s")]]' % colname).map do |table|
    title = table.xpath('preceding-sibling::h2').last.text
    wantcol = table.xpath('.//tr[1]//th').find_index { |td| td.text == colname }
    names = table.xpath('.//tr/td[%d]//a[not(@class="new")]/@title' % (wantcol+1)).map(&:text)
    puts "#{title}: #{names.count}"
    names
  end.flatten(1)
end

names_8 = wikinames8('https://zh.wikipedia.org/wiki/第8屆中華民國立法委員名單')
abort "No names for term 8" if names_8.count.zero?

names_9 = wikinames9('https://zh.wikipedia.org/wiki/第9屆中華民國立法委員名單')
abort "No names for term 9" if names_9.count.zero?

EveryPolitician::Wikidata.scrape_wikidata(names: { zh: (names_8 + names_9).uniq }, output: false)
EveryPolitician::Wikidata.notify_rebuilder

