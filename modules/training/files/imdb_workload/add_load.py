#!/usr/bin/python

import random
import time
from threading import Thread

from mysql.utilities.common import (database, options, server, table)

from subprocess import call
from contextlib import contextmanager


server_host = '127.0.0.1'
server_port = '3306'
server_user = 'plmce'
server_password = 'BelgianBeers'

server_connection = "%s:%s@%s:%s" % (server_user, server_password,
                                     server_host, server_port)

queries = (
u'SELECT * FROM imdb.title WHERE `id` = %(id)s;',
u'SELECT AVG(rating) avg FROM imdb.movie_ratings WHERE movie_id = %(id)s;',
u'SELECT * FROM imdb.cast_info WHERE movie_id = %(id)s and role_id = 1 ORDER BY nr_order ASC;',
u'SELECT * FROM imdb.name WHERE id = %(id)s;',
u'SELECT * FROM imdb.char_name WHERE id = %(id)s;',
u'SELECT * FROM imdb.comments ORDER BY id DESC limit 10;',
u'SELECT * FROM imdb.comments WHERE type="actor" and type_id = %(id)s ORDER BY id DESC;',
u'SELECT * FROM imdb.favorites WHERE user_id = %(id)s AND type="actor";',
u'SELECT * FROM imdb.favorites WHERE user_id = %(id)s AND type="movie";',
u'SELECT * FROM imdb.movie_info WHERE movie_id = %(id)s;',
u'SELECT * FROM imdb.person_info WHERE person_id = %(id)s;',
u'SELECT * FROM imdb.users WHERE last_login_date > NOW()-INTERVAL 10 MINUTE ORDER BY last_login_date DESC LIMIT 10;',
u'SELECT MAX(id) as c FROM imdb.name;',
u'SELECT MAX(id) as c FROM imdb.title;',
u'SELECT MAX(id) as c FROM imdb.users;',
u'SELECT user2 FROM imdb.user_friends WHERE user1 = %(id)s;',
u'SELECT cast_info.* FROM imdb.cast_info INNER JOIN imdb.title on (cast_info.movie_id=title.id) WHERE cast_info.person_id = %(id)s AND title.kind_id = 1 ORDER BY title.production_year DESC, title.id DESC;'
)


def memoize(func):
    cache = dict()

    def wrapper(*args, **kwargs):
        key = (func, args, frozenset(kwargs.items()))
        if key in cache:
            return cache.get(key)
        value = func(*args, **kwargs)
        cache[key] = value
        return value
    return wrapper


class Movie(object):

    def __init__(self,
                 server,
                 database=u"imdb"):
        self.server = server
        self.database = database

    @property
    @memoize
    def movie_db(self):
        """ Connect and return the connection to MySQL """
        return self.connect_db(self.database)

    @memoize
    def connect_db(self, db_name):
        """ Method to connect to MySQL """
        db_options = {u'skip_grants': True}
        return database.Database(self.server, db_name, db_options)

    def rnd_queries(self):
        query = queries[random.randint(0,len(queries)-1)]
        id=random.randint(0,5000)
        print query % {u'id': id}
        t=Thread(target=self.server.exec_query, args=(query % {u'id': id},))
        t.start()

def main():
    for x in range(1, random.randint(5,10)):
    	movie = Movie( server.get_server(u'localhost', server_connection, False))
    	movie.rnd_queries()
	time.sleep(0.5)

main()
