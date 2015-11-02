# Hadoop

####This folder include a simple hadoop application finding the business with largest employee amount per year.

# Files
## FindLargestBusiness.java

#### The hadoop application implemented in Java.

## FindLargestBusiness*.class

#### Compiled classes

## flb.jar

#### Jar file includes all classes

## make.sh

#### Shell Scripts I used for compiling and lunch standalone hadoop.

## input

#### The folder contains a file of data query from PostgresBD:

```sql
SELECT 
	b.year, b.naics_code, b.paid_employees, i.information
FROM
	labors_pattern AS b,
	industry AS i
WHERE
	b.naics_code > 0
	AND b.naics_code = i.naics_code;
```

## output

#### The folder includes the result of hadoop.

## result_sql.dat

#### The sql result. The query is:

```sql
SELECT DISTINCT ON (year) year, naics_code, paid_employees, information
FROM
labors_pattern
NATURAL JOIN industry
WHERE naics_code > 0
ORDER BY year ASC, paid_employees DESC;
```


