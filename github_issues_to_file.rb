#!/usr/bin/env ruby

# origin source
# https://gist.github.com/tkarpinski/2369729

require 'pp'
require 'pry'
require 'octokit'
require 'yaml'

# 設定ファイル読み出し
if File.exists?("info.yml")
  CONFIG = YAML.load_file("info.yml")
end

# Github credentials to access your private project
USERNAME = CONFIG["username"]
PASSWORD = CONFIG["password"]

# Project you want to export issues from
USER    = CONFIG["user"]
PROJECT = CONFIG["project"]

# Your local timezone offset to convert times
TIMEZONE_OFFSET="0"

Octokit.auto_paginate = true

def repo
  "#{USER}/#{PROJECT}"
end

def client
  @client = Octokit::Client.new(:login => USERNAME, :password => PASSWORD)
end

def milestone_number(name)
  @client.list_milestones(repo).select {|milestone|
    milestone.title.include?(name)
  }.first.number
end

def issues(options = {})
  client.list_issues(repo, :state => "open", milestone: milestone_number(options[:milestone]))
end

milestone_name = ARGV[0]

puts issues(milestone: milestone_name).map {|i|
  "#{Time.parse(i.updated_at)} -- #{i.title}"
}.sort

