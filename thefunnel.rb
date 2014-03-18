#!/usr/bin/env ruby

require 'pstore'
require 'colorize'
require_relative 'flashcard_set'
require_relative 'parser'

store = PStore.new(ARGV[0])

cardset = store.transaction(true) { store[:cardset] }
cardset ||= FlashcardSet.new

if ARGV[1] == 'add'
	puts "before:", cardset.questions_in_box.to_s
	Parser.parse File.open(ARGV[2]), cardset
	puts "after:", cardset.questions_in_box.to_s
elsif ARGV[1] == 'ask'
	puts "Welcome!", "Your Flashcard Box:", cardset.questions_in_box.to_s
	(ARGV[2] || 10).to_i.times do 
		cardset.ask do |question, answers|
			puts "\n\n\n\n\n\n"
			puts "Question: #{question}".light_cyan, '?????????????????????????????????????????????????????????????????????????????????????'.light_white
			$stdin.gets.chomp
			puts "Correct answer was:", answers.join("\n").green, "Was your answer correct?"
			next $stdin.gets.chomp == 'y'
		end
	end
	puts "Your Flashcard Box:", cardset.questions_in_box.to_s, "Goodbye"
end

store.transaction do
	store[:cardset] = cardset
end	