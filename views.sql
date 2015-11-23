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
	avg(i.variation) AS average_immigration_naturalized_total_annual_change,
	avg(i.variation_abs) AS average_immigration_naturalized_total_annual_change_absolution
FROM stat_immi_natu_vari AS i;

-- statistic assistant view, get the paid_employees and total_establishment variation between the current and the last year
CREATE OR REPLACE VIEW stat_bussi_patrn_annual_vari AS
SELECT
	t1.year AS year,
	t1.naics_code AS naics_code,
	t1.paid_employees - t2.paid_employees AS paid_employees_vari,
	abs(t1.paid_employees - t2.paid_employees) AS paid_employees_vari_abs,
	t1.total_establishment - t2.total_establishment AS total_establishment_vari,
	abs(t1.total_establishment - t2.total_establishment) AS total_establishment_vari_abs
FROM 
	labors_pattern AS t1,
	labors_pattern AS t2
WHERE
	t1.year = t2.year + 1
	AND t1.naics_code = t2.naics_code
ORDER BY naics_code ASC;

-- statistic assistant view, get the paid_employees and total_establishment annual average variation
CREATE OR REPLACE VIEW stat_bussi_patrn_annual_vari_avg AS
SELECT
	naics_code AS naics_code,
	avg(paid_employees_vari) AS average_paid_employees_annual_change,
	avg(paid_employees_vari_abs) AS average_paid_employees_annual_absolute_change,
	avg(total_establishment_vari) AS average_total_establishment_annual_change,
	avg(total_establishment_vari_abs) AS average_total_establishment_annual_absolute_change
FROM 
	stat_bussi_patrn_annual_vari GROUP BY naics_code
ORDER BY naics_code ASC;

-- statistic assistant view, get the annual variation of exchange rate from year 2000
CREATE OR REPLACE VIEW stat_exchange_annual_vari AS
SELECT
	t1.year AS year,
	t1.jpy - t2.jpy AS jpy_vari,
	t1.eur - t2.eur AS eur_vari,
	t1.gbp - t2.gbp AS gbp_vari,
	t1.cad - t2.cad AS cad_vari,
	t1.aud - t2.aud AS aud_vari,
	t1.rmb - t2.rmb AS rmb_vari
FROM
	exchange AS t1,
	exchange AS t2
WHERE
	t1.year = t2.year + 1
	AND t1.year > 1999
ORDER BY year ASC;

-- statistic assistant view, get the average annual variation of exchange rate
CREATE OR REPLACE VIEW stat_exchange_annual_vari_avg AS
SELECT
	avg(jpy_vari) AS average_jpy_to_usd_exchange_rate_annual_variation,
	avg(abs(jpy_vari)) AS average_jpy_to_usd_exchange_rate_annual_absolute_variation,
	avg(eur_vari) AS average_eur_to_usd_exchange_rate_annual_variation,
	avg(abs(eur_vari)) AS average_eur_to_usd_exchange_rate_annual_absolute_variation,
	avg(gbp_vari) AS average_gbp_to_usd_exchange_rate_annual_variation,
	avg(abs(gbp_vari)) AS average_gbp_to_usd_exchange_rate_annual_absolute_variation,
	avg(cad_vari) AS average_cad_to_usd_exchange_rate_annual_variation,
	avg(abs(cad_vari)) AS average_cad_to_usd_exchange_rate_annual_absolute_variation,
	avg(aud_vari) AS average_aud_to_usd_exchange_rate_annual_variation,
	avg(abs(aud_vari)) AS average_aud_to_usd_exchange_rate_annual_absolute_variation,
	avg(rmb_vari) AS average_rmb_to_usd_exchange_rate_annual_variation,
	avg(abs(rmb_vari)) AS average_rmb_to_usd_exchange_rate_annual_absolute_variation
FROM
	stat_exchange_annual_vari;

-- statistic assistant view, get the annual variation of international trade
CREATE OR REPLACE VIEW stat_inter_trade_annual_vari AS
SELECT
	t1.year AS year,
	t1.import_total - t2.import_total AS import_vari,
	t1.export_total - t2.export_total AS export_vari,
	t1.balance_total - t2.balance_total AS balance_vari
FROM
	trading AS t1,
	trading AS t2
WHERE
	t1.year = t2.year + 1
ORDER BY year ASC;

-- statistic assistant view, get the average annual variation of international trade
CREATE OR REPLACE VIEW stat_inter_trade_annual_vari_avg AS
SELECT
	avg(import_vari) AS average_international_import_annual_variation,
	avg(abs(import_vari)) AS average_international_import_annual_absolute_variation,
	avg(export_vari) AS average_international_export_annual_variation,
	avg(abs(export_vari)) AS average_international_export_annual_absolute_variation,
	avg(balance_vari) AS average_international_balance_annual_variation,
	avg(abs(balance_vari)) AS average_international_balance_annual_absolute_variation
FROM
	stat_inter_trade_annual_vari;

-- feature assistant view, get the peak of international trade(import)
CREATE OR REPLACE VIEW fetur_inter_trade_import_peak AS
SELECT
	t2.*,
	t1.import_total AS previous_year_import_total,
	t3.import_total AS next_year_import_total
FROM
	trading AS t1,
	trading AS t2,
	trading AS t3
WHERE
	t1.year = t2.year - 1
	AND t2.year = t3.year -1
	AND t1.import_total < t2.import_total
	AND t3.import_total < t2.import_total
ORDER BY year ASC;

-- feature assistant view, get the peak of international trade(export)
CREATE OR REPLACE VIEW fetur_inter_trade_export_peak AS
SELECT
	t2.*,
	t1.export_total AS previous_year_export_total,
	t3.export_total AS next_year_export_total
FROM
	trading AS t1,
	trading AS t2,
	trading AS t3
WHERE
	t1.year = t2.year - 1
	AND t2.year = t3.year -1
	AND t1.export_total < t2.export_total
	AND t3.export_total < t2.export_total
ORDER BY year ASC;

-- feature assistant view, get the peak of international trade(balance)
CREATE OR REPLACE VIEW fetur_inter_trade_balance_peak AS
SELECT
	t2.*,
	t1.import_total AS previous_year_balance_total,
	t3.import_total AS next_year_balance_total
FROM
	trading AS t1,
	trading AS t2,
	trading AS t3
WHERE
	t1.year = t2.year - 1
	AND t2.year = t3.year -1
	AND t1.balance_total < t2.balance_total
	AND t3.balance_total < t2.balance_total
ORDER BY year ASC;

-- feature assistant view, get the peak of international trade(import)
CREATE OR REPLACE VIEW fetur_inter_trade_import_valley AS
SELECT
	t2.*,
	t1.import_total AS previous_year_import_total,
	t3.import_total AS next_year_import_total
FROM
	trading AS t1,
	trading AS t2,
	trading AS t3
WHERE
	t1.year = t2.year - 1
	AND t2.year = t3.year -1
	AND t1.import_total > t2.import_total
	AND t3.import_total > t2.import_total
ORDER BY year ASC;

-- feature assistant view, get the peak of international trade(export)
CREATE OR REPLACE VIEW fetur_inter_trade_export_valley AS
SELECT
	t2.*,
	t1.export_total AS previous_year_export_total,
	t3.export_total AS next_year_export_total
FROM
	trading AS t1,
	trading AS t2,
	trading AS t3
WHERE
	t1.year = t2.year - 1
	AND t2.year = t3.year -1
	AND t1.export_total > t2.export_total
	AND t3.export_total > t2.export_total
ORDER BY year ASC;

-- feature assistant view, get the peak of international trade(balance)
CREATE OR REPLACE VIEW fetur_inter_trade_balance_valley AS
SELECT
	t2.*,
	t1.import_total AS previous_year_balance_total,
	t3.import_total AS next_year_balance_total
FROM
	trading AS t1,
	trading AS t2,
	trading AS t3
WHERE
	t1.year = t2.year - 1
	AND t2.year = t3.year -1
	AND t1.balance_total > t2.balance_total
	AND t3.balance_total > t2.balance_total
ORDER BY year ASC;

-- feature assistant view, get the largest business from every year
CREATE OR REPLACE VIEW fetur_largest_employee_bussi AS
SELECT DISTINCT ON (year) year, naics_code, paid_employees, information
FROM
labors_pattern
NATURAL JOIN industry
WHERE naics_code > 0
ORDER BY year ASC, paid_employees DESC;

CREATE OR REPLACE VIEW stat_enterprise_annu_vari(year, enterprise_vari) AS
SELECT
	year AS year,
	total_establishment_vari AS enterprise_vari
FROM
	stat_bussi_patrn_annual_vari
WHERE
	naics_code = 0
ORDER BY year ASC;

CREATE OR REPLACE VIEW stat_enterprise_annu_incr_rate(year, enterprise_inc_rate) AS
SELECT
	t1.year AS year,
	(t1.enterprise_vari - t2.enterprise_vari) / t2.enterprise_vari AS enterprise_inc_rate
FROM
	stat_enterprise_annu_vari AS t1,
	stat_enterprise_annu_vari AS t2
WHERE
	t1.year = t2.year - 1
ORDER BY year ASC;

CREATE OR REPLACE VIEW hypotest_pos_enterprise_trade(year, enterprise_inc_rate, import, export) AS
SELECT
	t1.year AS year,
	t1.enterprise_inc_rate AS enterprise_inc_rate,
	t2.import_total AS import,
	t2.export_total AS export
FROM
	stat_enterprise_annu_incr_rate AS t1,
	trading AS t2
WHERE
	t1.year = t2.year
ORDER BY year ASC;

CREATE OR REPLACE VIEW hypotest_no_11_export_service(year, paid_employees_11, export_service) AS
SELECT
	t1.year AS year,
	t1.paid_employees AS paid_employees_11,
	t2.export_service AS export_service
FROM
	labors_pattern AS t1,
	trading AS t2
WHERE
	t1.year = t2.year 
	AND t1.naics_code = 11
ORDER BY year ASC;

CREATE OR REPLACE VIEW hypotest_pos_51_52_61_export_service(year, sum_paid_employees_51_52_61, export_service) AS
SELECT
	year AS year,
	sum(paid_employees) AS sum_paid_employees_51_52_61,
	max(export_service) AS export_service
FROM
	labors_pattern 
	NATURAL JOIN trading
WHERE
	naics_code = 51
	OR naics_code = 52
	OR naics_code = 61
GROUP BY year
ORDER BY year ASC;

CREATE OR REPLACE VIEW hypotest_pos_immi_inc_rate_balance AS 
SELECT t1.year,
	(t2.variation::numeric - t1.variation::numeric) / t1.variation::numeric AS immi_inc_rate,
    t3.balance_total AS balance
FROM 
	stat_immi_natu_vari t1,
	stat_immi_natu_vari t2,
	trading t3
WHERE 
	t1.year = (t2.year - 1) 
	AND t3.year = t2.year
ORDER BY t1.year;

DROP VIEW stat_immi_natu_vari_avg;
DROP VIEW stat_immi_natu_vari;
