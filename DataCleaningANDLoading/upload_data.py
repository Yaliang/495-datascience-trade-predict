import os
import psycopg2
import urlparse

class database_obj:
	def __init__(self):
		database_url = "postgres://todqwhtumtlwxu:FwMJ6fGYhDa17vP1zxyi6R2K0j@ec2-54-227-253-238.compute-1.amazonaws.com:5432/db08ufnqsqd52b"
		urlparse.uses_netloc.append("postgres")
		url = urlparse.urlparse(database_url)

		self.conn = psycopg2.connect(
		    database=url.path[1:],
		    user=url.username,
		    password=url.password,
		    host=url.hostname,
		    port=url.port
		)

		self.cur = self.conn.cursor()

	def commit(self):
		self.conn.commit()

	def close(self):
		self.cur.close()
		self.conn.close()