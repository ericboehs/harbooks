#!/usr/bin/env ruby
#
# This script gathers time entries notes from your Harvest account. It will
# return 7 days worth of notes from the date specified.
#
# Usage: harbooks <client> <day of week start>
# Example: harbooks 'Acme Inc' 'April 12th'
#
# You will need the following ENV vars set:
#
# export HARVEST_SUBDOMAIN=acmeinc
# export HARVEST_USERNAME=rrunner
# export HARVEST_PASSWORD=beepbeep
#
# This script can be used by itself or inconjunction with bundler and/or dotenv:
#   - If a Gemfile is detected, bundler will be used
#   - If a .env file is detected, dotenv will make the config vars accesible
#
# LICENSE:
#
# (The MIT License)
#
# Copyright (c) Eric Boehs
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

begin require 'bundler/setup'; rescue LoadError; end
begin require 'dotenv';        rescue LoadError; end and Dotenv.load
begin
  require 'harvested'
rescue LoadError
  puts "Please install the harvested gem:\n  gem install harvested"
  exit
end

class Fixnum
  def ordinalize
    if (11..13).include?(self % 100)
      "#{self}th"
    else
      case self % 10
        when 1; "#{self}st"
        when 2; "#{self}nd"
        when 3; "#{self}rd"
        else    "#{self}th"
      end
    end
  end
end

class Harbooks
  def harvest
    @harvest ||= Harvest.client(
      ENV.fetch('HARVEST_SUBDOMAIN'),
      ENV.fetch('HARVEST_USERNAME'),
      ENV.fetch('HARVEST_PASSWORD')
    )
  end

  def invoice_notes(client, start_of_week)
    start_of_week = ::Date.parse start_of_week if start_of_week.is_a? String
    date_range = start_of_week..(start_of_week + 7)

    date_range.map do |day|
      time_entries = time_entries_for_client client, time_entries_for_day(day)
      day_notes_for_time_entries(time_entries, day) if time_entries.any?
    end.join.strip
  end

  def day_notes_for_time_entries(time_entries, day)
    "#{day_human(day)}\n#{time_entries.map{|te| te.notes }.join}\n\n"
  end

  def time_entries_for_day(day)
    harvest.time.all day
  end

  def time_entries_for_client(client, time_entries=nil)
    (time_entries || harvest.time.all).keep_if{|te| te.client == client}
  end

  def day_human(date)
    date.strftime "%B #{date.day.ordinalize}"
  end
end

if ARGV.length == 2
  begin
    Date.parse ARGV[1]
    puts Harbooks.new.invoice_notes ARGV[0], ARGV[1]
  rescue ArgumentError
    puts "Invalid date."
    puts "example usage: harbooks 'Acme Inc' 'April 12th'"
  end
else
  puts 'usage: harbooks <client> <day of week start>'
end
