import csv
from upload_data import database_obj


f = open("exchange.csv",'r')

reader = csv.reader(f)

d = {}
for year in xrange(1990,2015):
	d[year] = {
		'USD': 0,
		'JPY': 0,
		'EUR': 0,
		'GBP': 0,
		'CAD': 0,
		'AUD': 0,
		'RMB': 0
	}
for row in reader:
	if len(row) == 1:
		currency = row[0]
	else:
		year = int(row[0])
		d[year][currency] = float(row[1])
	# print row

# for year in xrange(1990, 2015):
# 	print d[year]

print d.keys()

f.close()

###### save to database
db = database_obj()
for year in d.keys():
	db.cur.execute('INSERT INTO exchange (year, RMB, USD, AUD, JPY, GBP, EUR, CAD) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)', 
		(int(year), float(d[year]['RMB']), float(d[year]['USD']), float(d[year]['AUD']), float(d[year]['JPY']), float(d[year]['GBP']), float(d[year]['EUR']), float(d[year]['CAD'])))

db.commit()
db.close()