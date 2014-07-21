class Question
	attr_reader :times_asked, :correct_streak, :topic

	def initialize question, question_context, topic, answers, ordered = false
		@question = question
		@question_context = question_context
		@topic = topic
		@answers = answers.is_a?(Array) ? answers : [answers]
		@ordered = ordered

		@times_asked = 0
		@correct_streak = 0
	end

	def answers delimiter = "\n"
		@answers.each_with_index.map { |answer, index| "#{ordered? ? index + 1 : '-'} #{answer}" }.join delimiter
	end

	def question
		q = ""
		q << @topic.map { |heading| "# #{heading}" }.join(' ') << ' - '
		q << @question_context.map { |question| "#{question} - " }.join('')
		q << @question
	end

	def ordered?
		@ordered
	end

	def is_in_topic? topic
		@topic[0, topic.size] == topic
	end

	def ask!
		@times_asked += 1
		return question, answers, @answers.size
	end

	def correct_answer!
		@correct_streak += 1
	end

	def wrong_answer!
		@correct_streak = 0
	end

	def box_position
		times_asked == 0 ? 0 : correct_streak + 1
	end
end