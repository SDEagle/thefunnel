require_relative 'spec_helper'
require_relative '../parser'

describe Parser do
	describe '::depth' do
		it 'interprets 4 spaces as a depth of one' do
			expect(Parser.depth('    foo')).to eq(1)
		end

		it 'interprets a tab as a depth of one' do
			expect(Parser.depth("\tfoo")).to eq(1)
		end
	end

	describe '::analyze_line' do
		it 'returns the depth' do
			expect(Parser.analyze_line("\t    ! foo")[0]).to eq(2)
		end

		it 'returns the items with their type' do
			_, items = Parser.analyze_line "\t    ! foo bar"
			expect(items[0]).to include(type: '!', text: 'foo bar')
		end

		it 'returns the items inside an array' do
			_, items = Parser.analyze_line "\t    ! foo * bar"
			expect(items).to match [
				a_hash_including(type: '!', text: 'foo'),
				a_hash_including(type: '*', text: 'bar')
			]
		end
	end

	describe '::split_into_items' do
		it 'returns individual items' do
			items = Parser.split_into_items '* foo ? bar ## bla bla ! 14 !2 nothing'
			expect(items).to match(['* foo', '? bar', '## bla bla', '! 14', '!2 nothing'])
		end

		it 'does not include unknown lines' do
			items = Parser.split_into_items 'bla bla * foo'
			expect(items).to eq(['* foo'])
			items = Parser.split_into_items 'bla bla'
			expect(items).to eq []
		end
	end

	describe '::construct_question' do
		it 'uses context' do
			question, answers = Parser.construct_question ['Topic'], [{question: 'Hitchhiker'}], { question: 'What ist the answer', answers: ['42']}
			expect(question).to eq('# Topic - Hitchhiker - What ist the answer')
			expect(answers).to eq(['42'])
		end

		it 'does not fail on empty context' do
			question, answers = Parser.construct_question [], [], { question: 'What ist the answer', answers: ['42']}
			expect(question).to eq('What ist the answer')
			expect(answers).to eq(['42'])
		end
	end


	describe '::parse' do
		it 'creates questions' do
			flashcards = double()
			expect(flashcards).to receive(:add_question).with('# Topic - What ist the answer', ['42'])
			Parser.parse("# Topic\n? What ist the answer\n\t! 42".each_line, flashcards)
		end

		it 'parses multiple answers in one line' do
			flashcards = double()
			expect(flashcards).to receive(:add_question).with('# Topic - What ist the answer', ['42', '23'])
			Parser.parse("# Topic\n? What ist the answer\n\t! 42 ! 23".each_line, flashcards)
		end

		it 'parses questions without answers' do
			flashcards = double()
			expect(flashcards).to receive(:add_question).with('# Topic - What ist the answer', ['42'])
			expect(flashcards).to receive(:add_question).with('# Topic - What ist the answer - 42', [])
			Parser.parse("# Topic\n? What ist the answer\n\t* 42".each_line, flashcards)
		end

		it 'continues with answers for higher level question after low level question is finished' do
			text = "# Topic
? Question
	* Subquestion
		! Subanswer
	! Answer"
			flashcards = double()
			expect(flashcards).to receive(:add_question).with('# Topic - Question', ['Subquestion', 'Answer'])
			expect(flashcards).to receive(:add_question).with('# Topic - Question - Subquestion', ['Subanswer'])
			Parser.parse(text.each_line, flashcards)
		end
	end
end