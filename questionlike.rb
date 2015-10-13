require_relative 'user'
require_relative 'question'
require_relative 'questionfollow'
require_relative 'reply'
require_relative 'questions'

class QuestionLike

  def self.all
    results = QuestionDatabase.instance.execute('SELECT * FROM question_likes')
    results.map { |result| QuestionLike.new(result) }
  end

  attr_accessor :user_id, :question_id

  def initialize(options = {})
    @question_id = options['question_id']
    @user_id = options['user_id']
  end


end
