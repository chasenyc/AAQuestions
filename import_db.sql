DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,


  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  reference_id INTEGER,
  body TEXT NOT NULL,


  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reference_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,


  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Doug','M'),
  ('Lily','R'),
  ('Alex', 'H');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('why?', 'why sql?????? :(', (SELECT id FROM users WHERE fname = 'Doug')),
  ('join type?', 'why inner vs. outer?', (SELECT id FROM users WHERE fname = 'Alex'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Doug'), (SELECT id FROM questions WHERE title = 'join type?')),
  ((SELECT id FROM users WHERE fname = 'Alex'), (SELECT id FROM questions WHERE title = 'why?'));

INSERT INTO
  replies (user_id, question_id, reference_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Doug'),
  (SELECT id FROM questions WHERE title = 'join type?'),
  NULL, 'definitely inner.');

INSERT INTO
  replies (user_id, question_id, reference_id, body)
VALUES
  ((SELECT id FROM users WHERE fname = 'Alex'),
  (SELECT id FROM questions WHERE title = 'join type?'),
  (SELECT id FROM replies WHERE body = 'definitely inner.'),
  'totally not.');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Lily'), (SELECT id FROM questions WHERE title = 'join type?'));
