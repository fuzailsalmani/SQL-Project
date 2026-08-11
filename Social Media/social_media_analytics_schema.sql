-- =====================================================================
-- SOCIAL MEDIA DATABASE — SCHEMA
-- Learning / portfolio project. NOT an official Social Media database.
-- Target: MySQL 8.0+
-- Author: Mo. Fuzail Salmani
-- =====================================================================

-- ---------------------------------------------------------------------
-- DATABASE
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS Social_Media;
USE Social_Media;

-- ---------------------------------------------------------
-- USERS TABLE
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    join_date DATE,
    country VARCHAR(150)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;

-- ---------------------------------------------------------
-- POSTS TABLE
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS posts (
    post_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    created_at DATETIME,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;

-- ---------------------------------------------------------
-- COMMENTS TABLE
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS comments (
    comment_id INT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT,
    created_at DATETIME,
    FOREIGN KEY (post_id)
        REFERENCES posts (post_id),
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;

-- ---------------------------------------------------------
-- LIKES TABLE
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS likes (
    like_id INT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME,
    FOREIGN KEY (post_id)
        REFERENCES posts (post_id),
    FOREIGN KEY (user_id)
        REFERENCES users (user_id)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;

-- ---------------------------------------------------------
-- FOLLOWERS TABLE (SELF JOIN)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS followers (
    follower_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    follower_user_id INT NOT NULL,
    follow_date DATE,
    FOREIGN KEY (user_id)
        REFERENCES users (user_id),
    FOREIGN KEY (follower_user_id)
        REFERENCES users (user_id)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;

-- ---------------------------------------------------------
-- HASHTAGS TABLE
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS hashtags (
    hashtag_id INT PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL,
    category VARCHAR(50)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;

-- ---------------------------------------------------------
-- POST_HASHTAGS TABLE
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS post_hashtags (
    id INT PRIMARY KEY,
    post_id INT NOT NULL,
    hashtag_id INT NOT NULL,
    FOREIGN KEY (post_id)
        REFERENCES posts (post_id),
    FOREIGN KEY (hashtag_id)
        REFERENCES hashtags (hashtag_id)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;