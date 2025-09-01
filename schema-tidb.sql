CREATE DATABASE IF NOT EXISTS imdbload;
USE imdbload;

CREATE TABLE IF NOT EXISTS aka_name (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id INT NOT NULL,
    name VARCHAR(255),
    imdb_index VARCHAR(3),
    name_pcode_cf VARCHAR(11),
    name_pcode_nf VARCHAR(11),
    surname_pcode VARCHAR(11),
    md5sum VARCHAR(65)
);

CREATE TABLE IF NOT EXISTS aka_title (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    title VARCHAR(255),
    imdb_index VARCHAR(4),
    kind_id INT NOT NULL,
    production_year INT,
    phonetic_code VARCHAR(5),
    episode_of_id INT,
    season_nr INT,
    episode_nr INT,
    note VARCHAR(72),
    md5sum VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS cast_info (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id INT NOT NULL,
    movie_id INT NOT NULL,
    person_role_id INT,
    note VARCHAR(255),
    nr_order INT,
    role_id INT NOT NULL
);

CREATE TABLE IF NOT EXISTS char_name (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    imdb_index VARCHAR(2),
    imdb_id INT,
    name_pcode_nf VARCHAR(5),
    surname_pcode VARCHAR(5),
    md5sum VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS comp_cast_type (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    kind VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS company_name (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    country_code VARCHAR(6),
    imdb_id INT,
    name_pcode_nf VARCHAR(5),
    name_pcode_sf VARCHAR(5),
    md5sum VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS company_type (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    kind VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS complete_cast (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    subject_id INT NOT NULL,
    status_id INT NOT NULL
);

CREATE TABLE IF NOT EXISTS info_type (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    info VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS keyword (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    keyword VARCHAR(255) NOT NULL,
    phonetic_code VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS kind_type (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    kind VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS link_type (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    link VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS movie_companies (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    company_id INT NOT NULL,
    company_type_id INT NOT NULL,
    note VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS movie_info_idx (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    info_type_id INT NOT NULL,
    info VARCHAR(255) NOT NULL,
    note VARCHAR(1)
);

CREATE TABLE IF NOT EXISTS movie_keyword (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    keyword_id INT NOT NULL
);

CREATE TABLE IF NOT EXISTS movie_link (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    linked_movie_id INT NOT NULL,
    link_type_id INT NOT NULL
);

CREATE TABLE IF NOT EXISTS name (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    imdb_index VARCHAR(9),
    imdb_id INT,
    gender VARCHAR(1),
    name_pcode_cf VARCHAR(5),
    name_pcode_nf VARCHAR(5),
    surname_pcode VARCHAR(5),
    md5sum VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS role_type (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    role VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS title (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    imdb_index VARCHAR(5),
    kind_id INT NOT NULL,
    production_year INT,
    imdb_id INT,
    phonetic_code VARCHAR(5),
    episode_of_id INT,
    season_nr INT,
    episode_nr INT,
    series_years VARCHAR(49),
    md5sum VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS movie_info (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    movie_id INT NOT NULL,
    info_type_id INT NOT NULL,
    info VARCHAR(255) NOT NULL,
    note VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS person_info (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    person_id INT NOT NULL,
    info_type_id INT NOT NULL,
    info VARCHAR(255) NOT NULL,
    note VARCHAR(255)
);
