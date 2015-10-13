
require_relative 'question'
require_relative 'questionfollow'
require_relative 'reply'
require_relative 'questionlike'
require_relative 'questions'
require_relative 'modelbase'

class User < ModelBase
  TABLE_NAME = 'users'

  def self.find_by_name(fname,lname)
    results = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(result.first)
  end



  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    results = QuestionDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        CAST(COUNT(question_likes.question_id)/COUNT(questions.id) AS FLOAT)
      FROM
        questions
      LEFT OUTER JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      JOIN
        users
      ON
        users.id = questions.user_id

      WHERE
        users.id = ?
    SQL
    results.first.values.first
  end

end
