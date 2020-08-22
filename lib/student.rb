require_relative "../config/environment.rb"
require 'pry'
class Student
  attr_accessor :name, :grade, :id
  # has a name and a grade
  # has an id that defaults to `nil` on initialization

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table 
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
    # binding pry
    # creates the students table in the database
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL

    DB[:conn].execute(sql)
    # drops the students table from the database
  end

  def save
    if self.id
      update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
 
  def update
    sql = <<-SQL
      UPDATE students 
        SET name = ?, grade = ?
        WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

    def self.create(name, grade)
      Student.new(name, grade).tap {|student| student.save}
    end

    def self.new_from_db(array)
      Student.new(array[1], array[2], array[0])
    end

    def self.find_by_name(name)
      sql = <<-SQL 
        SELECT * FROM students
        WHERE name = ?
        LIMIT 1
      SQL
  
      DB[:conn].execute(sql, name).map do |row|
        new_from_db(row)
      end.first
    end

    def update
      sql = <<-SQL
        UPDATE students 
          SET name = ?, grade = ?
          WHERE id = ?
      SQL
  
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

end
