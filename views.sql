CREATE VIEW stat_immi_natu_total (year, total) AS SELECT year, naturalized_total FROM immigration;

CREATE VIEW stat_immi_natu_vari (year, variation, variation_abs) AS
SELECT 
	t1.year AS year, 
	t1.total - t2.total AS variation,
	abs(t1.total-t2.total) AS variation_abs
FROM 
	stat_immi_natu_total AS t1, 
	stat_immi_natu_total AS t2
WHERE t1.year = t2.year+1;

CREATE VIEW stat_immi_natu_vari_avg AS
SELECT 
	avg(i.variation) AS avg,
	avg(i.variation_abs) AS avg_abs
FROM stat_immi_natu_vari AS i;


DROP VIEW stat_immi_natu_vari_avg;
DROP VIEW stat_immi_natu_vari;
DROP VIEW stat_immi_natu_total;