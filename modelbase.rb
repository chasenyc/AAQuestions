class ModelBase
  def self.find_by_id(id, table)
    result = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL
    self.new(result.first)
  end

end
