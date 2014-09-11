require_relative '../question'

describe Question do
	let(:question) { Question.new('Question', ['Context'], ['Topic'], ['Some answer', 'Another answer']) }

	describe '#question' do
		it 'returns the question' do
			expect(Question.new('Question').question).to be == 'Question'
		end

		it 'prepends question context' do
			expect(Question.new('Question', ['Context']).question).to be == 'Context - Question'
		end

		it 'prepends topics' do
			expect(Question.new('Question', [], ['Topic']).question).to be == '# Topic - Question'
		end
	end

	describe '#answers' do
		let (:question) { Question.new('', [], [], ['Some answer', 'Another answer'])}
		let (:ordered_question) { Question.new('', [], [], ['Some answer', 'Another answer'], true)}
		it 'returns all the answers' do
			expect(question.answers).to be == "- Some answer\n- Another answer"
		end

		context 'when ordered' do
			it 'numbers the answers' do
				expect(ordered_question.answers).to be == "1 Some answer\n2 Another answer"
			end
		end

		context 'when passed a delimiter' do
			it 'uses the delimiter instead of newline' do
				expect(question.answers('*')).to be == "- Some answer*- Another answer"
			end
		end
	end

	describe '#==' do
		context 'when used the standard way' do
			it 'is compares also stats' do
				question2 = question.clone
				expect(question == question2).to be_truthy
				question2.correct_answer!
				expect(question == question2).to be_falsy
			end
		end

		context 'with stats ignored' do
			it 'compares only actual question data' do
				question2 = question.clone
				question2.correct_answer!
				expect(question.==(question2, true)).to be_truthy
			end
		end
	end

	describe '#is_in_topic?' do
		it 'is part of its own topic' do
			expect(question.is_in_topic? ['Topic']).to be_truthy
		end

		it 'is not part of other topics' do
			expect(question.is_in_topic? ['Other']).to be_falsy
		end

		it 'is part of greater topics' do
			expect(question.is_in_topic? []).to be_truthy
		end

		it 'is not part of subtopics' do
			expect(question.is_in_topic? ['Topic', 'Subtopic']).to be_falsy
		end
	end
end