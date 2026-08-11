-- =====================================================================
-- NETFLIX DATABASE CLONE — SCHEMA
-- Learning / portfolio project. NOT an official Netflix database.
-- Target: MySQL 8.0+
-- =====================================================================

-- ---------------------------------------------------------------------
-- DATABASE
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS netflix_clone;
CREATE DATABASE netflix_clone
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE netflix_clone;

-- ---------------------------------------------------------------------
-- TABLE CREATION
-- ---------------------------------------------------------------------

-- GENRES ---------------------------------------------------------------
CREATE TABLE genres (
    genre_id     INT AUTO_INCREMENT PRIMARY KEY,
    genre_name   VARCHAR(50)  NOT NULL,
    description  VARCHAR(255) NULL,
    CONSTRAINT uq_genre_name UNIQUE (genre_name)
) ENGINE=InnoDB;

-- ACTORS -----------------------------------------------------------------
CREATE TABLE actors (
    actor_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    date_of_birth DATE         NOT NULL,
    nationality   VARCHAR(50)  NOT NULL,
    CONSTRAINT chk_actor_dob CHECK (date_of_birth <= CURRENT_DATE())
) ENGINE=InnoDB;

-- MOVIES -------------------------------------------------------------
CREATE TABLE movies (
    movie_id         INT AUTO_INCREMENT PRIMARY KEY,
    title             VARCHAR(150) NOT NULL,
    release_year      SMALLINT     NOT NULL,
    duration_minutes  SMALLINT     NOT NULL,
    description       VARCHAR(500) NULL,
    language          VARCHAR(50)  NOT NULL,
    country           VARCHAR(50)  NOT NULL,
    age_rating        VARCHAR(10)  NOT NULL DEFAULT 'PG-13',
    release_date      DATE         NOT NULL,
    CONSTRAINT chk_movie_year CHECK (release_year BETWEEN 1900 AND 2100),
    CONSTRAINT chk_movie_duration CHECK (duration_minutes > 0),
    CONSTRAINT chk_movie_age_rating CHECK (age_rating IN ('G','PG','PG-13','R','NC-17','TV-MA','TV-14','TV-PG'))
) ENGINE=InnoDB;

-- TV_SHOWS -----------------------------------------------------------
CREATE TABLE tv_shows (
    show_id             INT AUTO_INCREMENT PRIMARY KEY,
    title                VARCHAR(150) NOT NULL,
    release_year         SMALLINT     NOT NULL,
    end_year             SMALLINT     NULL,
    number_of_seasons    SMALLINT     NOT NULL DEFAULT 1,
    description          VARCHAR(500) NULL,
    language             VARCHAR(50)  NOT NULL,
    country               VARCHAR(50)  NOT NULL,
    age_rating            VARCHAR(10)  NOT NULL DEFAULT 'TV-14',
    CONSTRAINT chk_show_year CHECK (release_year BETWEEN 1900 AND 2100),
    CONSTRAINT chk_show_end_year CHECK (end_year IS NULL OR end_year >= release_year),
    CONSTRAINT chk_show_seasons CHECK (number_of_seasons > 0),
    CONSTRAINT chk_show_age_rating CHECK (age_rating IN ('G','PG','PG-13','R','NC-17','TV-MA','TV-14','TV-PG','TV-Y','TV-Y7'))
) ENGINE=InnoDB;

-- MOVIE_GENRES (many-to-many: movies <-> genres) ----------------------
CREATE TABLE movie_genres (
    movie_id  INT NOT NULL,
    genre_id  INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_mg_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT fk_mg_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- SHOW_GENRES (many-to-many: tv_shows <-> genres) ---------------------
CREATE TABLE show_genres (
    show_id   INT NOT NULL,
    genre_id  INT NOT NULL,
    PRIMARY KEY (show_id, genre_id),
    CONSTRAINT fk_sg_show  FOREIGN KEY (show_id)  REFERENCES tv_shows(show_id) ON DELETE CASCADE,
    CONSTRAINT fk_sg_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- MOVIE_ACTORS (many-to-many: movies <-> actors) ----------------------
CREATE TABLE movie_actors (
    movie_id   INT NOT NULL,
    actor_id   INT NOT NULL,
    role_name  VARCHAR(100) NULL,
    PRIMARY KEY (movie_id, actor_id),
    CONSTRAINT fk_ma_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT fk_ma_actor FOREIGN KEY (actor_id) REFERENCES actors(actor_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- SHOW_ACTORS (many-to-many: tv_shows <-> actors) ---------------------
CREATE TABLE show_actors (
    show_id    INT NOT NULL,
    actor_id   INT NOT NULL,
    role_name  VARCHAR(100) NULL,
    PRIMARY KEY (show_id, actor_id),
    CONSTRAINT fk_sa_show  FOREIGN KEY (show_id)  REFERENCES tv_shows(show_id) ON DELETE CASCADE,
    CONSTRAINT fk_sa_actor FOREIGN KEY (actor_id) REFERENCES actors(actor_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- RATINGS ------------------------------------------------------------------
-- A rating belongs to EITHER a movie OR a tv_show, never both and never
-- neither. This is enforced with two nullable FKs + a CHECK constraint
-- instead of a single polymorphic column, so referential integrity is
-- still guaranteed by the database (a "polymorphic association" without
-- real foreign keys would silently allow orphaned/invalid references).
CREATE TABLE ratings (
    rating_id      INT AUTO_INCREMENT PRIMARY KEY,
    content_type   ENUM('movie','show') NOT NULL,
    movie_id       INT NULL,
    show_id        INT NULL,
    rating_value   DECIMAL(3,1) NOT NULL,
    rating_count   INT NOT NULL DEFAULT 0,
    rated_at       DATE NOT NULL DEFAULT (CURRENT_DATE()),
    CONSTRAINT fk_rating_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
    CONSTRAINT fk_rating_show  FOREIGN KEY (show_id)  REFERENCES tv_shows(show_id) ON DELETE CASCADE,
    CONSTRAINT chk_rating_value CHECK (rating_value BETWEEN 0 AND 10),
    CONSTRAINT chk_rating_count CHECK (rating_count >= 0),
    CONSTRAINT chk_rating_target CHECK (
        (content_type = 'movie' AND movie_id IS NOT NULL AND show_id IS NULL)
        OR
        (content_type = 'show'  AND show_id  IS NOT NULL AND movie_id IS NULL)
    )
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- INDEXES
-- (Primary/foreign keys are already indexed by InnoDB; these extra
--  indexes speed up common lookup/filter/sort patterns.)
-- ---------------------------------------------------------------------
CREATE INDEX idx_movies_title        ON movies(title);
CREATE INDEX idx_movies_release_year ON movies(release_year);
CREATE INDEX idx_movies_country      ON movies(country);
CREATE INDEX idx_movies_language     ON movies(language);

CREATE INDEX idx_shows_title         ON tv_shows(title);
CREATE INDEX idx_shows_release_year  ON tv_shows(release_year);
CREATE INDEX idx_shows_country       ON tv_shows(country);

CREATE INDEX idx_actors_last_name    ON actors(last_name);
CREATE INDEX idx_actors_nationality  ON actors(nationality);

CREATE INDEX idx_ratings_movie       ON ratings(movie_id);
CREATE INDEX idx_ratings_show        ON ratings(show_id);
CREATE INDEX idx_ratings_value       ON ratings(rating_value);
