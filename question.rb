class Question
	attr_reader :times_asked, :correct_streak

	def initialize question, answers, ordered = false
		@question = question
		@answers = answers.is_a?(Array) ? answers : [answers]
		@ordered = ordered

		@times_asked = 0
		@correct_streak = 0
	end

	def ordered?
		@ordered
	end

	def answers delimiter = "\n"
		@answers.each_with_index.map { |answer, index| "#{ordered? ? index + 1 : '-'} #{answer}" }.join delimiter
	end

	def ask!
		@times_asked += 1
		return @question, @answers
	end

	def correct_answer!
		@correct_streak += 1
	end

	def wrong_answer!
		@correct_streak = 0
	end
end