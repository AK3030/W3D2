DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL


);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES reply(id),
  FOREIGN KEY (user_id) REFERENCES user(id)

);

DROP TABLE IF EXISTS likes;

CREATE TABLE likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);



INSERT INTO
  users (fname, lname)
VALUES
  ('Alex', 'Kite'),
  ('Areej', 'Hassan'),
  ('bob', 'smith');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Why?', "akldsfjalksdf", 1),
  ('How?', "dalfkjdsfadflkj", 3),
  ('Where?', "ewoiusnvn", 2);

INSERT INTO
  replies (question_id, parent_reply_id, user_id, body)
VALUES
  (1, NULL, 1, "Because"),
  (2, NULL, 1, "Tajkfl"),
  (2, 1, 3, "adlskfj");

  INSERT INTO
    question_follows (question_id, user_id)
  VALUES
    (3, 2),
    (1, 1),
    (3, 3);

  INSERT INTO
    likes (user_id, question_id)
  VALUES
    (1, 1),
    (2, 1),
    (3, 3); 
