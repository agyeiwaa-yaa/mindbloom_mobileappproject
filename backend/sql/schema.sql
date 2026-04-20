CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY,
  full_name VARCHAR(100),
  email VARCHAR(120),
  created_at DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS mood_entries (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  mood VARCHAR(30) NOT NULL,
  score INT NOT NULL,
  note TEXT,
  created_at DATETIME NOT NULL,
  location_name VARCHAR(120),
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS journal_entries (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  title VARCHAR(150) NOT NULL,
  content TEXT NOT NULL,
  mood VARCHAR(30),
  image_path TEXT,
  created_at DATETIME NOT NULL,
  location_name VARCHAR(120),
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS habits (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  name VARCHAR(120) NOT NULL,
  icon_key VARCHAR(50) NOT NULL,
  color_value INT NOT NULL,
  target_per_week INT NOT NULL,
  reminder_enabled TINYINT(1) NOT NULL DEFAULT 0,
  reminder_hour INT NULL,
  reminder_minute INT NULL,
  archived TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS habit_completions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  habit_id VARCHAR(36) NOT NULL,
  completed_on DATE NOT NULL,
  FOREIGN KEY (habit_id) REFERENCES habits(id)
);

CREATE TABLE IF NOT EXISTS reminders (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  title VARCHAR(150) NOT NULL,
  body TEXT NOT NULL,
  hour INT NOT NULL,
  minute INT NOT NULL,
  type VARCHAR(50) NOT NULL,
  reference_id VARCHAR(36),
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS app_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  setting_key VARCHAR(80) NOT NULL,
  setting_value TEXT NOT NULL,
  UNIQUE KEY unique_user_setting (user_id, setting_key),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
