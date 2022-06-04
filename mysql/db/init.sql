-- Creation of users table
CREATE TABLE IF NOT EXISTS users (
  user_id INT NOT NULL,
  name varchar(250) NOT NULL,
  PRIMARY KEY (user_id)
);