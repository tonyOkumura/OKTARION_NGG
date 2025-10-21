CREATE TABLE IF NOT EXISTS contacts (
  id UUID PRIMARY KEY,
  username VARCHAR(255) UNIQUE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  display_name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(30) UNIQUE,
  is_online BOOLEAN NOT NULL DEFAULT false,
  last_seen_at TIMESTAMP,
  status_message VARCHAR(255),
  role VARCHAR(20) NOT NULL DEFAULT 'user',
  department VARCHAR(255),
  rank VARCHAR(100),
  position VARCHAR(255),
  company VARCHAR(255),
  avatar_url VARCHAR(500),
  date_of_birth DATE,
  locale VARCHAR(10) DEFAULT 'ru',
  timezone TEXT DEFAULT 'Europe/Moscow',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX ON contacts (username);

CREATE UNIQUE INDEX ON contacts (email);

CREATE UNIQUE INDEX ON contacts (phone);