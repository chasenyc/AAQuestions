require 'singleton'
require 'sqlite3'

class QuestionDatabase < SQLite3::Database
include Singleton

  def initialize
    # Tell the SQLite3::Database the db file to read/write.
    super('questions.db')

    # Typically each row is returned as an array of values; it's more
    # convenient for us if we receive hashes indexed by column name.
    self.results_as_hash = true

    # Typically all the data is returned as strings and not parsed
    # into the appropriate type.
    self.type_translation = true
  end
end

class User
  def self.all

    results = QuestionDatabase.instance.execute('SELECT * FROM users')
    results.map { |result| User.new(result) }
  end

  def self.find_by(id)
    result = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(result)
  end

  def self.find_by_fname_lname(fname,lname)
    result = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(result)
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end

class Question

  def self.all
    results = QuestionDatabase.instance.execute('SELECT * FROM questions')
    results.map { |result| Question.new(result) }
  end

  def self.find_by(id)
    result = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(result)
  end

  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

end

class QuestionFollow
  def self.all
    results = QuestionDatabase.instance.execute('SELECT * FROM question_follows')
    results.map { |result| QuestionFollow.new(result) }
  end

  attr_accessor :user_id, :question_id

  def initialize(options = {})
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end

class Reply
  def self.all
    results = QuestionDatabase.instance.execute('SELECT * FROM replies')
    results.map { |result| Reply.new(result) }
  end

  def self.find_by(id)
    result = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Reply.new(result)
  end

  attr_accessor :id, :body, :user_id, :question_id, :reference_id

  def initialize(options = {})
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @reference_id = options['reference_id']
    @body = options['body']

  end
end

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
