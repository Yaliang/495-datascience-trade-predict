import requests
import csv
from upload_data import database_obj

root_url = "http://censtats.census.gov/cgi-bin/cbpnaic/cbpsect.csv"

for year in xrange(1998, 2012):

	###### request the data from the web
	r = requests.post(root_url, data = {
		"Year": str(year),
		"County": "000",
		"Noise": "NO",
		"State": "00",
		"LFO": "NO"
		})

	##### cut the first table
	res = r.content
	res = res[:res.index('\r\n\r\n\r\nNumber of establishments by employment-size class'):]
	res = res[res.index('Total establishments\"\r\n')+len('Total establishments\"\r\n')::]
	# print res

	## extract csv into a list of dicts
	fieldnames=['naics_code', 'code_description', 'paid_employees', 'season', 'annual', 'total_establish']
	reader = csv.reader(res)

	i = -1
	line = -1
	d = []
	for row in reader:
		if len(row) == 1:
			i += 1
			if i % len(fieldnames) == 0:
				d.append({})
				line += 1
			d[line][fieldnames[i % len(fieldnames)]] = row[0]

	for i in xrange(line+1):
		d[i][fieldnames[0]] = d[i][fieldnames[0]].replace('-','')
		if len(d[i][fieldnames[0]]) == 0:
			d[i][fieldnames[0]] = '0'

		## replace 'i' code with '-2' 
		if d[i][fieldnames[2]] == 'i':
			d[i][fieldnames[2]] = '-2'
		## replace 'j' code with '-1'
		if d[i][fieldnames[2]] == 'j':
			d[i][fieldnames[2]] = '-1'
		# print d[i]

	##### cut the second table
	res = r.content
	res = res[res.index('\'1000 or more\'\"\r\n')+len('\'1000 or more\'\"\r\n')+2::]
	
	## extract csv into dicts
	fieldnames_2=['naics_code', 'code_description', 'total_establish', 'size_1_4', 'size_5_9', 'size_10_19', 'size_20_49', 'size_50_99', 'size_100_249', 'size_250_499', 'size_500_900', 'size_1000']
	reader = csv.reader(res)
	i = -1
	line = -1
	for row in reader:
		if len(row) == 1:
			i += 1
			if i % len(fieldnames_2) == 0:
				line += 1
			if i % len(fieldnames_2) > 2:
				d[line][fieldnames_2[i % len(fieldnames_2)]] = row[0]

	# check the dicts
	# for i in xrange(line+1):
	# 	print d[i]



	###### save to database
	db = database_obj()
	fieldnames = ['naics_code', 'paid_employees', 'season', 'annual', 'total_establish','size_1_4', 'size_5_9', 'size_10_19', 'size_20_49', 'size_50_99', 'size_100_249', 'size_250_499', 'size_500_900', 'size_1000']
	for i in xrange(line+1):
		db.cur.execute('INSERT INTO labors_pattern (year, naics_code, paid_employees, season, annual, total_establishment, size_1_4, size_5_9, size_10_19, size_20_49, size_50_99, size_100_249, size_250_499, size_500_900, size_1000) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)', 
			(int(year), int(d[i][fieldnames[0]]), float(d[i][fieldnames[1]]), float(d[i][fieldnames[2]]), float(d[i][fieldnames[3]]), float(d[i][fieldnames[4]]), float(d[i][fieldnames[5]]), float(d[i][fieldnames[6]]), float(d[i][fieldnames[7]]), float(d[i][fieldnames[8]]), float(d[i][fieldnames[9]]), float(d[i][fieldnames[10]]), float(d[i][fieldnames[11]]), float(d[i][fieldnames[12]]), float(d[i][fieldnames[13]])))

	db.commit()
	db.close()

	print year, "done."
