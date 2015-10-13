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

  def self.likers_for_question_id(question_id)
    results = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
      question_likes
    JOIN
      users
    ON
      question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
    results.map { |result| User.new(result) }

  end

  def self.num_likes_for_question_id(question_id)
    num = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      count(users.id)
    FROM
      question_likes
    JOIN
      users
    ON
      question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
    num.first.values.first
  end


  attr_accessor :user_id, :question_id

  def initialize(options = {})
    @question_id = options['question_id']
    @user_id = options['user_id']
  end



end
