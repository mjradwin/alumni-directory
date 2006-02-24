-- $Id: alumni.sql,v 1.6 2006/02/22 06:47:08 mradwin Exp mradwin $

DROP TABLE IF EXISTS aid_alumnus;
DROP TABLE IF EXISTS aid_entry;
DROP TABLE IF EXISTS aid_reunion;
DROP TABLE IF EXISTS aid_verify;
DROP TABLE IF EXISTS aid_bounce;
DROP TABLE IF EXISTS aid_limit;

CREATE TABLE aid_alumnus (
alumnus_id INT NOT NULL auto_increment,
alumnus_status TINYINT(4) NOT NULL,
alumnus_entry_id INT NOT NULL,
alumnus_old_id INT,
alumnus_create DATETIME NOT NULL,
alumnus_update TIMESTAMP NOT NULL,
PRIMARY KEY (alumnus_id)
) CHARACTER SET latin1;

CREATE TABLE aid_entry (
entry_id INT NOT NULL auto_increment,
entry_name_surname VARCHAR(100) NOT NULL,	-- Last Name/Maiden Name
entry_name_married VARCHAR(100),	-- Married Last Name
entry_name_given VARCHAR(100) NOT NULL,	-- First Name
entry_name_mi VARCHAR(1),	-- Middle Initial
entry_email VARCHAR(200) NOT NULL,	-- E-mail Address
entry_gradclass YEAR(4),	-- Graduation Year or NULL for Other
entry_affil_other VARCHAR(40), -- "Teacher" or some non-gradyear affiliation
entry_web_page VARCHAR(1024),	-- Personal Web Page
entry_location VARCHAR(100),	-- Location
entry_note TEXT,
entry_reunion TINYINT(1) NOT NULL,	-- bit for reunion email request
PRIMARY KEY (entry_id),
KEY entry_email (entry_email),
KEY entry_gradclass (entry_gradclass),
FULLTEXT (entry_name_surname,entry_name_married,entry_name_given)
) CHARACTER SET latin1;

CREATE TABLE aid_reunion (
reunion_gradclass VARCHAR(100) NOT NULL,
reunion_date DATE,
reunion_text TEXT NOT NULL,
PRIMARY KEY (reunion_gradclass)
) CHARACTER SET latin1;

CREATE TABLE aid_verify (
verify_code VARCHAR(24) NOT NULL,
verify_staging_id INT NOT NULL,
verify_alumnus_id INT,
verify_created DATETIME NOT NULL,
verify_confirmed DATETIME,
verify_published DATETIME,
PRIMARY KEY verify_code (verify_code)
) CHARACTER SET latin1;

CREATE TABLE aid_bounce (
bounce_email VARCHAR(200) NOT NULL,
bounce_time TIMESTAMP NOT NULL,
bounce_reason TEXT,
bounce_std_reason VARCHAR(16),
KEY bounce_email (bounce_email)
) CHARACTER SET latin1;

CREATE TABLE aid_limit (
limit_name VARCHAR(30),
limit_count TINYINT,
PRIMARY KEY (limit_name)
) CHARACTER SET latin1;

/*
CREATE TABLE aid_timestamps (
ts_name varchar(20),
ts_time TIMESTAMP NOT NULL,
PRIMARY KEY (ts_name)
) CHARACTER SET latin1;
*/
