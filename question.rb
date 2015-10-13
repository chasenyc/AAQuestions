require_relative 'user'
require_relative 'questionfollow'
require_relative 'reply'
require_relative 'questionlike'
require_relative 'questions'

class Question

  def self.all
    results = QuestionDatabase.instance.execute('SELECT * FROM questions')
    results.map { |result| Question.new(result) }
  end

  def self.find_by_id(id)
    results = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(results.first)
  end

  def self.find_by_author_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(self.user_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

end