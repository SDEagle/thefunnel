class Parser

	def initialize lines, flashcard_set, topic = []
		@lines = lines
		@flashcard_set = flashcard_set
		@topic = topic
	end

	def parse
		@context = []
		expected_depth = 0
		@heading_context = []
		current_heading_level = 0

		@lines.each do |line|
			depth, items = analyze_line(line)

			items.each do |item|
				while depth < expected_depth
					add_question!
					expected_depth -= 1
				end

				if item[:type] =~ /#+/
					heading_level = item[:type].size

					if heading_level <= current_heading_level
						@heading_context.pop(current_heading_level - heading_level + 1)
					end
					@heading_context << item[:text]
					current_heading_level = heading_level
				else
					if item[:type] =~ /(!|\*)/
						@context[-1][:answers] << item[:text]
					end
					if item[:type] =~ /(\?|\*)/
						@context << { question: item[:text], answers: [] }
						expected_depth = depth + 1
					end	
				end
			end
		end

		while !@context.empty?
			add_question!
		end
	end

	def analyze_line line
		items = split_into_items(line.lstrip).map do |item|  
			Hash[[:type, :text].zip item.split(/\s/, 2)]
		end
		return depth(line), items
	end

	def depth line
		line.gsub("\t", '    ')[/\A */].size / 4
	end

	def split_into_items line
		line.scan(/(([!\*\?]|(?<!#)#+)[^!\*\?#]*)/).map { |item| item[0].strip }
	end

	def add_question!
		question_data = @context.pop
		question = Question.new question_data[:question], @context.map { |q| q[:question] }, @heading_context.clone, question_data[:answers]
		@flashcard_set.add_question question if question.is_in_topic? @topic
	end
end