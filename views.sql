-- statistic assistant view, get the total number of naturalized population --
CREATE OR REPLACE VIEW stat_immi_natu_total (year, total) AS SELECT year, naturalized_total FROM immigration;

-- statistic assistant view, get the variation (and the absolute value) between the current and the last year(current-last) --
CREATE OR REPLACE VIEW stat_immi_natu_vari (year, variation, variation_abs) AS
SELECT 
	t1.year AS year, 
	t1.naturalized_total - t2.naturalized_total AS variation,
	abs(t1.naturalized_total-t2.naturalized_total) AS variation_abs
FROM 
	-- rename the immigration table as two different tables
	immigration AS t1, 
	immigration AS t2
WHERE t1.year = t2.year+1;

-- statistic assistant view, get the average value of annual variation in view::stat_immi_natu_vari --
CREATE OR REPLACE VIEW stat_immi_natu_vari_avg AS
SELECT 
	avg(i.variation) AS avg,
	avg(i.variation_abs) AS avg_abs
FROM stat_immi_natu_vari AS i;

-- statistic assistant function, get the paid_employees and total_establishment of a specific NAICS class ascending by year -- 
CREATE OR REPLACE FUNCTION labors_pattern_by_naics(naics_code labors_pattern.naics_code%TYPE) 
	RETURNS TABLE (year labors_pattern.year%TYPE, paid_employees labors_pattern.paid_employees%TYPE, total_establishment labors_pattern.total_establishment%TYPE)
AS $$
	SELECT labors_pattern.year, labors_pattern.paid_employees, labors_pattern.total_establishment
	FROM labors_pattern AS labors_pattern
	WHERE
		labors_pattern.naics_code = $1
	ORDER BY year ASC;
$$ LANGUAGE SQL;

-- statistic assistant function, get the variation between the current and the last year --
CREATE OR REPLACE FUNCTION labors_pattern_annual_vari_by_naics(naics_code labors_pattern.naics_code%TYPE)
	RETURNS TABLE (year labors_pattern.year%TYPE, paid_employees_vari labors_pattern.paid_employees%TYPE, total_establishment_vari labors_pattern.total_establishment%TYPE)
AS $$
	SELECT
		t1.year AS year,
		t1.paid_employees - t2.paid_employees AS paid_employees_vari,
		t1.total_establishment - t2.total_establishment AS total_establishment_vari
	FROM
		labors_pattern_by_naics($1) AS t1,
		labors_pattern_by_naics($1) AS t2
	WHERE
		t1.year = t2.year + 1
	ORDER BY year ASC;
$$ LANGUAGE SQL;

DROP VIEW stat_immi_natu_vari_avg;
DROP VIEW stat_immi_natu_vari;
DROP VIEW stat_immi_natu_total;