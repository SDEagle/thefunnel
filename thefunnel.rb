#!/usr/bin/env ruby

require 'pstore'
require 'colorize'
require_relative 'flashcard_set'
require_relative 'parser'

store = PStore.new ARGV[0]

cardset = store.transaction(true) { store[:cardset] }
cardset ||= FlashcardSet.new

def select_topic topics
	puts "Choose a topic (by index)"
	topics = topics.sort
	puts "0/*: - ALL"
	topics.each_with_index do |topic, i|
		puts "#{i + 1}: #{topic.join ' - '}"
	end
	selection = $stdin.gets.chomp
	return [] if selection == '' || selection == '0' || selection == '*'
	topics[selection.to_i - 1]
end

if ARGV[1] == 'add'
	puts "before:", cardset.to_s
	Parser.new(File.open(ARGV[2]), cardset).parse
	puts "after:", cardset.to_s
elsif ARGV[1] == 'ask'
	topic = select_topic cardset.topics
	old = cardset.topic_stats topic
	puts "Welcome!", "Your Flashcard Box:", old
	question_count = cardset.total_questions

	(ARGV[2] || 10).to_i.times do 
		cardset.ask(topic) do |question, answers, number_of_answers|
			puts "\n\n\n\n\n\n"
			puts "Question: #{question} (#{number_of_answers} answers)".light_cyan, '?????????????????????????????????????????????????????????????????????????????????????'.light_white
			$stdin.gets.chomp
			puts "Correct answer was:", answers.green, "Was your answer correct?"
			next $stdin.gets.chomp == 'y'
		end
	end

	puts "Your Flashcard Box:", "Before:", old, "Now:", cardset.topic_stats(topic), "Goodbye"
	raise 'Broken card moves' unless question_count == cardset.total_questions
elsif ARGV[1] == 'update'
	puts "before:", cardset.to_s
	topic = select_topic cardset.topics

	cardset.remove_topic topic
	Parser.new(File.open(ARGV[2]), cardset, topic).parse
	puts "after:", cardset.to_s
elsif ARGV[1] == 'stats'
	topic = select_topic cardset.topics	
	puts cardset.topic_stats topic
end

store.transaction do
	store[:cardset] = cardset
end	