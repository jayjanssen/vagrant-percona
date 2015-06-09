#!/usr/bin/python

import random
import time
import string

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
u'SELECT * FROM imdb.name WHERE id = %(id)s;',
u'SELECT * FROM imdb.char_name WHERE id = %(id)s;',
u'SELECT * FROM imdb.comments ORDER BY id DESC limit 10;',
u'SELECT * FROM imdb.favorites WHERE user_id = %(id)s AND type="actor";',
u'SELECT * FROM imdb.favorites WHERE user_id = %(id)s AND type="movie";',
u'SELECT * FROM imdb.movie_info WHERE movie_id = %(id)s;',
u'SELECT * FROM imdb.person_info WHERE person_id = %(id)s;',
u'SELECT user2 FROM imdb.user_friends WHERE user1 = %(id)s;',
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

    def rnd_user(self):
        query = u"INSERT INTO imdb.users (email_address, first_name, last_name) VALUES ('%(email)s','%(first_name)s','%(last_name)s');"
        f_name = self.genstring(3,9)
        l_name = self.genstring(4,12)
        email =  "%(f_name)s.%(l_name)s@jaimail.com" % {u'f_name': f_name, u'l_name': l_name}
        print query % {u'email': email, u'first_name': f_name, u'last_name': l_name}
        t=Thread(target=self.server.exec_query, args=(query % {u'email': email, u'first_name': f_name, u'last_name': l_name},))
        t.start()

    def genstring(self,lim_down=3,lim_up=9):
	    alpha = random.randint(lim_down,lim_up)
	    vowels = ['a','e','i','o','u']
	    consonants = [a for a in string.ascii_lowercase if a not in vowels]

	    ####utility functions
	    def a_part(slen):
		ret = ''
		for i in range(slen):
		    if i%2 ==0:
			randid = random.randint(0,20) #number of consonants
			ret += consonants[randid]
		    else:
			randid = random.randint(0,4) #number of vowels
			ret += vowels[randid]
		return ret

	    def n_part(slen):
		ret = ''
		for i in range(slen):
		    randid = random.randint(0,9) #number of digits
		    ret += digits[randid]
		return ret

	    ####        
	    fpl = alpha/2
	    if alpha % 2 :
		fpl = int(alpha/2) + 1
	    lpl = alpha - fpl

	    start = a_part(fpl)
	    end = a_part(lpl)

	    return "%s%s" % (start.capitalize(),end)

def main():
    while True:
        try:
    	    movie = Movie( server.get_server(u'localhost', server_connection, False))
    	    movie.rnd_queries()
	    time.sleep(0.5)
            movie.rnd_user()
	    time.sleep(10)
	except:
	    time.sleep(30)

main()
