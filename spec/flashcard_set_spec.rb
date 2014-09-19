require_relative 'spec_helper'
require_relative '../flashcard_set'
require_relative '../question'

describe FlashcardSet do
	let (:box) { FlashcardSet.new }
	let (:question) { Question.new 'foo' }

	describe '#contains?' do
		context 'with an empty box' do
			it 'returns false on any question' do
				expect(box.contains? question).to be_falsy
			end
		end

		context 'with existing questions' do
			it 'finds existing questions' do
				box.add_question question
				expect(box.contains? question).to be_truthy
			end

			it 'does not find noncontained questions' do
				box.add_question question
				expect(box.contains? Question.new('foobar')).to be_falsy
			end

			it 'ignores questions stats' do
				box.add_question question
				q = Question.new 'foo'
				q.correct_answer!
				expect(box.contains? q).to be_truthy
			end
		end
	end

	describe '#add_question' do
		it 'does not add existing questions' do
			box.add_question question
			expect { box.add_question question }.to_not change { box.total_questions }
		end
	end

	describe '#update' do
		context 'with an empty box' do
			it 'adds all questions' do
				expect(parser = double('parser')).to receive(:parse) do |&block|
					block.call(question)
					block.call(Question.new 'bar')
				end
				expect { box.update parser }.to change { box.total_questions }.by(2)
			end
		end

		context 'with existing questions' do
			it 'adds only new questions' do
				box.add_question question
				parser = double('parser')
				expect(parser = double('parser')).to receive(:parse) do |&block|
					block.call(question)
					block.call(Question.new 'bar')
				end
				expect { box.update parser }.to change { box.total_questions }.by(1)
			end

			it 'removes old questions which werent added' do
				box.add_question question
				expect(parser = double('parser')).to receive(:parse)
				box.update parser
				expect(box.contains? question).to be_falsy
			end

			it 'keeps stats' do
				box.add_question question
				box.ask { true }
				expect(parser = double('parser')).to receive(:parse) do |&block|
					block.call(Question.new 'foo')
				end
				expect { box.update parser }.to_not change { box.questions_in_box[2] }
			end
		end 
	end
end