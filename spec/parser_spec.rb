require_relative 'spec_helper'
require_relative '../parser'

describe Parser do
	let (:parser) { Parser.new '' }

	describe '#depth' do
		it 'interprets 4 spaces as a depth of one' do
			expect(parser.depth('    foo')).to eq(1)
		end

		it 'interprets a tab as a depth of one' do
			expect(parser.depth("\tfoo")).to eq(1)
		end
	end

	describe '#analyze_line' do
		it 'returns the depth' do
			expect(parser.analyze_line("\t    ! foo")[0]).to eq(2)
		end

		it 'returns the items with their type' do
			_, items = parser.analyze_line "\t    ! foo bar"
			expect(items[0]).to include(type: '!', text: 'foo bar')
		end

		it 'returns the items inside an array' do
			_, items = parser.analyze_line "\t    ! foo * bar"
			expect(items).to match [
				a_hash_including(type: '!', text: 'foo'),
				a_hash_including(type: '*', text: 'bar')
			]
		end
	end

	describe '#split_into_items' do
		it 'returns individual items' do
			items = parser.split_into_items '* foo ? bar ## bla bla ! 14 !2 nothing'
			expect(items).to match(['* foo', '? bar', '## bla bla', '! 14', '!2 nothing'])
		end

		it 'recognizes if there is no space before *' do
			items = parser.split_into_items '! 14*2'
			expect(items).to match(['! 14*2'])
		end

		it 'does not include unknown lines' do
			items = parser.split_into_items 'bla bla * foo'
			expect(items).to eq(['* foo'])
			items = parser.split_into_items 'bla bla'
			expect(items).to eq []
		end
	end

	describe '::parse' do
		it 'creates questions' do
			expect { |b| Parser.new("# Topic\n? What ist the answer\n\t! 42".each_line).parse(&b) }.to yield_successive_args(Question.new('What ist the answer', [], ['Topic'], ['42']))
		end

		it 'parses multiple answers in one line' do
			expect { |b| Parser.new("# Topic\n? What ist the answer\n\t! 42 ! 23".each_line).parse(&b) }.to yield_successive_args(Question.new('What ist the answer', [], ['Topic'], ['42', '23']))
		end

		it 'parses questions without answers' do
			expect { |b| Parser.new("# Topic\n? What ist the answer\n\t* 42".each_line).parse(&b) }.to yield_successive_args(
				Question.new('42', ['What ist the answer'], ['Topic'], []),
				Question.new('What ist the answer', [], ['Topic'], ['42']))
		end

		it 'continues with answers for higher level question after low level question is finished' do
			text = "# Topic
? Question
	* Subquestion
		! Subanswer
	! Answer"
			expect { |b| Parser.new(text.each_line).parse(&b) }.to yield_successive_args(
				Question.new('Subquestion', ['Question'], ['Topic'], ['Subanswer']),
				Question.new('Question', [], ['Topic'], ['Subquestion', 'Answer']))
		end
	end
end