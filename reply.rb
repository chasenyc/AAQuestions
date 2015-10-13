require_relative 'user'
require_relative 'question'
require_relative 'questionfollow'
require_relative 'questionlike'
require_relative 'questions'
require_relative 'modelbase'

class Reply < ModelBase
  TABLE_NAME = 'replies'

  def self.find_by_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

  def self.find_by_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :body, :user_id, :question_id, :reference_id

  def initialize(options = {})
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @reference_id = options['reference_id']
    @body = options['body']

  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    Reply.find_by_id(self.reference_id)
  end

  def child_reply
    results = QuestionDatabase.instance.execute(<<-SQL, self.id)
    SELECT
      *
    FROM
     replies
    WHERE
      reference_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end

end
