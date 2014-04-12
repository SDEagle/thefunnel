#!/usr/bin/env ruby

require 'pstore'
require 'colorize'
require_relative 'flashcard_set'
require_relative 'parser'

store = PStore.new(ARGV[0])

cardset = store.transaction(true) { store[:cardset] }
cardset ||= FlashcardSet.new

if ARGV[1] == 'add'
	puts "before:", cardset.to_s
	Parser.parse File.open(ARGV[2]), cardset
	puts "after:", cardset.to_s
elsif ARGV[1] == 'ask'
	old = cardset.to_s
	puts "Welcome!", "Your Flashcard Box:", old
	question_count = cardset.total_questions

	(ARGV[2] || 10).to_i.times do 
		cardset.ask do |question, answers|
			puts "\n\n\n\n\n\n"
			puts "Question: #{question} (#{answers.size} answers)".light_cyan, '?????????????????????????????????????????????????????????????????????????????????????'.light_white
			$stdin.gets.chomp
			puts "Correct answer was:", answers.join("\n").green, "Was your answer correct?"
			next $stdin.gets.chomp == 'y'
		end
	end

	puts "Your Flashcard Box:", "Before:", old, "Now:", cardset.to_s, "Goodbye"
	raise 'Broken card moves' unless question_count == cardset.total_questions
end

store.transaction do
	store[:cardset] = cardset
end	