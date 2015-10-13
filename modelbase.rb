class ModelBase

  def self.where(table, params= {})
    params_and_values = []
    params.each do |k,v|
      params_and_values << "#{k} = '#{v}'"
    end
    params_and_values = params_and_values.join(' AND ')

    result = QuestionDatabase.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table}
    WHERE
      #{params_and_values}
    SQL

    result.map { |result| self.new(result) }
  end

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

  def self.all(table)
    results = QuestionDatabase.instance.execute("SELECT * FROM #{table}")
    results.map { |result| self.new(result) }

  end

  def save(table)
    params = self.instance_variables
    params.delete(:@id)
    final_values = []
    final_params = []
    final_questions = "(#{params.map{ "?" }.join(", ")})"
    update_params = []
    params.each do |param|
      final_values << self.send(param[1..-1])
      final_params << param[1..-1]
      update_params << "#{param[1..-1]} = ?"
    end
    final_params = "(#{final_params.join(', ')})"
    update_params = update_params.join(', ')

      if self.id.nil?
        QuestionDatabase.instance.execute(<<-SQL, *final_values)
        INSERT INTO
          #{table} #{final_params}
        VALUES
          #{final_questions}
        SQL
        self.id = QuestionDatabase.instance.last_insert_row_id
      else
        QuestionDatabase.instance.execute(<<-SQL, *final_values, self.id)
        UPDATE
          #{table}
        SET #{update_params}
        WHERE
          #{table}.id = ?
        SQL
      end
  end

end
