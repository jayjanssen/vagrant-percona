ALTER TABLE movie_info ADD INDEX movie_id (movie_id);
ALTER TABLE cast_info ADD INDEX movie_id (movie_id), ADD INDEX person_id (person_id);
