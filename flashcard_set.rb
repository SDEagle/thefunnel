require_relative 'question'

class FlashcardSet
	def initialize
		@boxes = [[]]
	end

	def add_question question
		@boxes[0] << question
	end

	def clean
		@boxes = @boxes.flatten.uniq.group_by { |q| q.box_position }
	end

	def ask topic = []
		question = random_question
		while !question.is_in_topic? topic
			question = random_question
		end

		@boxes[question.box_position].delete(question)

		if yield(*question.ask!)
			question.correct_answer!
		else 
			question.wrong_answer!
		end

		@boxes[question.box_position] ||= []
		@boxes[question.box_position] << question
	end

	def topics
		questions.map { |question| question.topic }.uniq
	end

	def questions_in_box topic = []
		filtered_boxes(topic).map &:size
	end

	def total_questions topic = []
		questions_in_box(topic).inject 0, &:+
	end

	def remove_topic topic
		@boxes.each do |box|
			box.reject! { |question| question.is_in_topic? topic }
		end
	end

	def topic_stats topic = []
		"Total Number of questions: #{total_questions(topic)} - in boxes: #{questions_in_box(topic).to_s}"
	end

	def to_s
		topic_stats
	end

private

	def filtered_boxes topic = []
		@boxes.map { |box| box.reject { |q| !q.is_in_topic? topic } }
	end

	def questions
		@boxes.flatten
	end
	
	def random_question
		ticket_to_question(rand(ticket_count))
	end

	def ticket_count
		tickets_per_box.inject(0, &:+)
	end

	def tickets_per_box
		@boxes.each_with_index.map { |box, index| box.size * tickets_per_question(index) }
	end

	def tickets_per_question box_index
		2 ** (@boxes.size - box_index - 1)
	end

	def ticket_to_question ticket
		box = nil
		tickets_per_box.each_with_index do |ticket_count, index|
			if ticket < ticket_count
				box = index
				break
			end
			ticket -= ticket_count
		end

		ticket /= tickets_per_question(box)
		@boxes[box][ticket]
	end
end