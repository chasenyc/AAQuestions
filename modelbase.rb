class ModelBase

  def self.method_missing(method_name, *args)
    method_name = method_name.to_s
    if method_name.start_with?("find_by_")
      attributes_string = method_name[("find_by_".length)..-1]

      attribute_names = attributes_string.split("_and_")

      unless attribute_names.length == args.length
        raise "unexpected # of arguments"
      end

      search_conditions = {}
      attribute_names.each_with_index do |el, i|
        search_conditions[el] = args[i]
      end
      self.where(search_conditions)
    else
      super
    end
  end

  def self.where(params= {})
    if params.is_a?(String)
      each_search = params.split(" AND ")
      param_str = []
      values = []
      each_search.each do |search|
        three_things = search.split(" ")
        param_str << "#{three_things[0]} #{three_things[1]} ?"
        values << three_things[2]
      end

      param_str = param_str.join(' AND ')
    else

      param_str = []
      values = []
      params.each do |k,v|
        param_str << "#{k} = ?"
        values << v
      end
      param_str = param_str.join(' AND ')
    end
    result = QuestionDatabase.instance.execute(<<-SQL, *values)
    SELECT
      *
    FROM
      #{self::TABLE_NAME}
    WHERE
      #{param_str}
    SQL

    result.map { |result| self.new(result) }

  end

  def self.find_by_id(id)
    result = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        id = ?
    SQL
    self.new(result.first)
  end

  def self.all
    results = QuestionDatabase.instance.execute("SELECT * FROM #{self::TABLE_NAME}")
    results.map { |result| self.new(result) }

  end

  def save
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
    p final_values
    p final_params
    p final_questions
      if self.id.nil?
        QuestionDatabase.instance.execute(<<-SQL, *final_values)
        INSERT INTO
          #{self.class::TABLE_NAME} #{final_params}
        VALUES
          #{final_questions}
        SQL
        #self.id = QuestionDatabase.instance.last_insert_row_id
      else
        QuestionDatabase.instance.execute(<<-SQL, *final_values, self.id)
        UPDATE
          #{self::TABLE_NAME}
        SET #{update_params}
        WHERE
          #{self::TABLE_NAME}.id = ?
        SQL
      end
  end

end
