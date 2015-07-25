# Assumes mysql is already installed in some form
include training::imdb::imdb
include training::my_movies
include test::user

include mysql::service
