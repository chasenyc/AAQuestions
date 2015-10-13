require_relative 'user'
require_relative 'question'
require_relative 'reply'
require_relative 'questionlike'
require_relative 'questions'

class QuestionFollow
  def self.all
    results = QuestionDatabase.instance.execute('SELECT * FROM question_follows')
    results.map { |result| QuestionFollow.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM
      question_follows
    JOIN
      questions
    ON
      question_follows.question_id = questions.id
    GROUP BY
      questions.title, question_follows.question_id
    ORDER BY
      COUNT(question_follows.question_id) DESC
    LIMIT ?
    SQL
    results.map { |result| Question.new(result) }
end

  def self.followers_for_question_id(question_id)
      results = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN
        users
      ON
        users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
      SQL
      results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(user_id)
    results = QuestionDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_follows
    JOIN
      questions
    ON
      questions.id = question_follows.question_id
    WHERE
      question_follows.user_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  attr_accessor :user_id, :question_id

  def initialize(options = {})
    @question_id = options['question_id']
    @user_id = options['user_id']
  end



end
