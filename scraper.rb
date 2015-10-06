#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'wikidata/fetcher'
require 'nokogiri'
require 'open-uri'
require 'pry'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def wikinames(url)
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

names = wikinames('https://zh.wikipedia.org/wiki/%E7%AC%AC8%E5%B1%86%E4%B8%AD%E8%8F%AF%E6%B0%91%E5%9C%8B%E7%AB%8B%E6%B3%95%E5%A7%94%E5%93%A1%E5%90%8D%E5%96%AE')
abort "No names" if names.count.zero?

WikiData.ids_from_pages('zh', names).each_with_index do |p, i|
  data = WikiData::Fetcher.new(id: p.last).data('zh') rescue nil
  unless data
    warn "No data for #{p}"
    next
  end
  ScraperWiki.save_sqlite([:id], data)
end
