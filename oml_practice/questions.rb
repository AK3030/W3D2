require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')

    self.type_translation = true
    self.results_as_hash = true
  end
end


class QuestionLike
  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      likes
    JOIN
      users ON users.id = likes.user_id
    WHERE
      question_id = ?
    SQL
    return nil if likers.empty?
    likers.map {|liker| User.new(liker)}
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(user_id) AS count
    FROM
      likes
    WHERE
      question_id = ?
    SQL
    return nil if likes.empty?
    likes[0]['count']
  end

  def self.liked_questions_for_user_id(user_id)

  end

end



class Question
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil unless !question.empty?
    Question.new(question.first)
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless !question.empty?
    Question.new(question.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
end




class User
  attr_accessor :fname, :lname
  def self.find_by_name(fname, lname)
    name = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless name.length > 0
    User.new(name.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']

  end

  def save
    raise "#{self}already saved" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
    INSERT INTO
      users (fname, lname)
    VALUES
      (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end
end




class QuestionFollow
  attr_accessor :question_id, :user_id

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      COUNT(question_follows.user_id), questions.title, questions.body, questions.author_id
    FROM
      question_follows
    JOIN
      questions ON question_follows.question_id = questions.id
    GROUP BY
      question_id
    ORDER BY
      COUNT(user_id) DESC
    LIMIT
      ?
    SQL

    return nil if questions.empty?
    questions.map {|question_hash| Question.new(question_hash)}
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_follows
      JOIN users
        ON question_follows.user_id = users.id
      WHERE
        question_id = ?
    SQL

    users.map {|user_hash| User.new(user_hash)}

  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        question_follows
      JOIN questions
        ON question_follows.question_id = questions.id
      WHERE
        user_id = ?
    SQL

    questions.map {|question_hash| Question.new(question_hash)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end



class Reply
  attr_accessor :question_id, :parent_reply_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
  end

  def find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
      SQL
      return nil unless !name.empty?
      Reply.new(reply)
  end



end
