class Parser

	def self.parse lines, flashcard_set
		context = []
		expected_depth = 0
		heading_context = []
		current_heading_level = 0

		lines.each do |line|
			depth, items = analyze_line(line)

			items.each do |item|
				while depth < expected_depth
					flashcard_set.add_question(*construct_question(heading_context, context, context.pop))
					expected_depth -= 1
				end

				if item[:type] =~ /#+/
					heading_level = item[:type].size

					if heading_level <= current_heading_level
						heading_context.pop(current_heading_level - heading_level + 1)
					end
					heading_context << item[:text]
					current_heading_level = heading_level
				else
					if item[:type] =~ /(!|\*)/
						context[-1][:answers] << item[:text]
					end
					if item[:type] =~ /(\?|\*)/
						context << { question: item[:text], answers: [] }
						expected_depth = depth + 1
					end	
				end
			end
		end

		while !context.empty?
			flashcard_set.add_question(*construct_question(heading_context, context, context.pop))
		end
	end

	def self.analyze_line line
		items = split_into_items(line.lstrip).map do |item|  
			Hash[[:type, :text].zip item.split(/\s/, 2)]
		end
		return depth(line), items
	end

	def self.depth line
		line.gsub("\t", '    ')[/\A */].size / 4
	end

	def self.split_into_items line
		line.scan(/(([!\*\?]|(?<!#)#+)[^!\*\?#]*)/).map { |item| item[0].strip }
	end

	def self.construct_question heading_context, question_context, question
		q = ""
		q << "# #{heading_context.join ' # '} - " unless heading_context.empty?
		q << "#{question_context.map {|q| q[:question]}.join ' - '} - " unless question_context.empty?
		q << question[:question]
		return q, question[:answers]
	end
end