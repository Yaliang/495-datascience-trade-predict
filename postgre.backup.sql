--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: labors_pattern_annual_vari_by_naics(integer); Type: FUNCTION; Schema: public; Owner: todqwhtumtlwxu
--

CREATE FUNCTION labors_pattern_annual_vari_by_naics(naics_code integer) RETURNS TABLE(year integer, paid_employees_vari double precision, total_establishment_vari double precision)
    LANGUAGE sql
    AS $_$
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
$_$;


ALTER FUNCTION public.labors_pattern_annual_vari_by_naics(naics_code integer) OWNER TO todqwhtumtlwxu;

--
-- Name: labors_pattern_by_naics(integer); Type: FUNCTION; Schema: public; Owner: todqwhtumtlwxu
--

CREATE FUNCTION labors_pattern_by_naics(naics_code integer) RETURNS TABLE(year integer, paid_employees double precision, total_establishment double precision)
    LANGUAGE sql
    AS $_$
	SELECT labors_pattern.year, labors_pattern.paid_employees, labors_pattern.total_establishment
	FROM labors_pattern AS labors_pattern
	WHERE
		labors_pattern.naics_code = $1
	ORDER BY year ASC;
$_$;


ALTER FUNCTION public.labors_pattern_by_naics(naics_code integer) OWNER TO todqwhtumtlwxu;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: exchange; Type: TABLE; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE TABLE exchange (
    year integer NOT NULL,
    usd double precision,
    jpy double precision,
    eur double precision,
    gbp double precision,
    cad double precision,
    aud double precision,
    rmb double precision
);


ALTER TABLE exchange OWNER TO todqwhtumtlwxu;

--
-- Name: immigration; Type: TABLE; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE TABLE immigration (
    petitions integer,
    naturalized_total integer,
    naturalized_civilian integer,
    naturalized_military integer,
    naturalized_np integer,
    denied integer,
    year integer NOT NULL
);


ALTER TABLE immigration OWNER TO todqwhtumtlwxu;

--
-- Name: industry; Type: TABLE; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE TABLE industry (
    nacis_code integer NOT NULL,
    information text NOT NULL
);


ALTER TABLE industry OWNER TO todqwhtumtlwxu;

--
-- Name: labors_pattern; Type: TABLE; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE TABLE labors_pattern (
    sampleid bigint NOT NULL,
    year integer NOT NULL,
    naics_code integer NOT NULL,
    paid_employees double precision,
    season double precision,
    annual double precision,
    total_establishment double precision,
    size_1_4 double precision,
    size_5_9 double precision,
    size_10_19 double precision,
    size_20_49 double precision,
    size_50_99 double precision,
    size_100_249 double precision,
    size_250_499 double precision,
    size_500_900 double precision,
    size_1000 double precision
);


ALTER TABLE labors_pattern OWNER TO todqwhtumtlwxu;

--
-- Name: COLUMN labors_pattern.paid_employees; Type: COMMENT; Schema: public; Owner: todqwhtumtlwxu
--

COMMENT ON COLUMN labors_pattern.paid_employees IS '-1 represents code j: meaning 10,000-24,999 employees
-2 represents code i: meaning 5,000-9,999 employees';


--
-- Name: labors_pattern_sampleid_seq; Type: SEQUENCE; Schema: public; Owner: todqwhtumtlwxu
--

CREATE SEQUENCE labors_pattern_sampleid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE labors_pattern_sampleid_seq OWNER TO todqwhtumtlwxu;

--
-- Name: labors_pattern_sampleid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: todqwhtumtlwxu
--

ALTER SEQUENCE labors_pattern_sampleid_seq OWNED BY labors_pattern.sampleid;


--
-- Name: naturalized_rate; Type: VIEW; Schema: public; Owner: todqwhtumtlwxu
--

CREATE VIEW naturalized_rate AS
 SELECT immigration.petitions,
    immigration.naturalized_total,
    immigration.naturalized_civilian,
    immigration.naturalized_military,
    immigration.naturalized_np,
    immigration.denied,
    immigration.year,
    (((immigration.naturalized_total)::numeric + 0.0) / ((immigration.petitions)::numeric + 0.0)) AS naturalizde_rate
   FROM immigration;


ALTER TABLE naturalized_rate OWNER TO todqwhtumtlwxu;

--
-- Name: stat_immi_natu_total; Type: VIEW; Schema: public; Owner: todqwhtumtlwxu
--

CREATE VIEW stat_immi_natu_total AS
 SELECT immigration.year,
    immigration.naturalized_total AS total
   FROM immigration;


ALTER TABLE stat_immi_natu_total OWNER TO todqwhtumtlwxu;

--
-- Name: stat_immi_natu_vari; Type: VIEW; Schema: public; Owner: todqwhtumtlwxu
--

CREATE VIEW stat_immi_natu_vari AS
 SELECT t1.year,
    (t1.naturalized_total - t2.naturalized_total) AS variation,
    abs((t1.naturalized_total - t2.naturalized_total)) AS variation_abs
   FROM immigration t1,
    immigration t2
  WHERE (t1.year = (t2.year + 1));


ALTER TABLE stat_immi_natu_vari OWNER TO todqwhtumtlwxu;

--
-- Name: stat_immi_natu_vari_avg; Type: VIEW; Schema: public; Owner: todqwhtumtlwxu
--

CREATE VIEW stat_immi_natu_vari_avg AS
 SELECT avg(i.variation) AS avg,
    avg(i.variation_abs) AS avg_abs
   FROM stat_immi_natu_vari i;


ALTER TABLE stat_immi_natu_vari_avg OWNER TO todqwhtumtlwxu;

--
-- Name: time; Type: TABLE; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE TABLE "time" (
    year integer NOT NULL
);


ALTER TABLE "time" OWNER TO todqwhtumtlwxu;

--
-- Name: totalmax; Type: VIEW; Schema: public; Owner: todqwhtumtlwxu
--

CREATE VIEW totalmax AS
 SELECT a.year,
    max(a.total_establishment) AS total
   FROM labors_pattern a
  WHERE (a.naics_code > 0)
  GROUP BY a.year
  ORDER BY a.year;


ALTER TABLE totalmax OWNER TO todqwhtumtlwxu;

--
-- Name: trading; Type: TABLE; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE TABLE trading (
    sampleid bigint NOT NULL,
    year integer,
    import_total integer,
    export_total integer,
    balance_total integer,
    import_service integer,
    import_goods integer,
    export_service integer,
    export_goods integer
);


ALTER TABLE trading OWNER TO todqwhtumtlwxu;

--
-- Name: trading_sampleid_seq; Type: SEQUENCE; Schema: public; Owner: todqwhtumtlwxu
--

CREATE SEQUENCE trading_sampleid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE trading_sampleid_seq OWNER TO todqwhtumtlwxu;

--
-- Name: trading_sampleid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: todqwhtumtlwxu
--

ALTER SEQUENCE trading_sampleid_seq OWNED BY trading.sampleid;


--
-- Name: sampleid; Type: DEFAULT; Schema: public; Owner: todqwhtumtlwxu
--

ALTER TABLE ONLY labors_pattern ALTER COLUMN sampleid SET DEFAULT nextval('labors_pattern_sampleid_seq'::regclass);


--
-- Name: sampleid; Type: DEFAULT; Schema: public; Owner: todqwhtumtlwxu
--

ALTER TABLE ONLY trading ALTER COLUMN sampleid SET DEFAULT nextval('trading_sampleid_seq'::regclass);


--
-- Name: exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

ALTER TABLE ONLY exchange
    ADD CONSTRAINT exchange_pkey PRIMARY KEY (year);


--
-- Name: immagration_pkey; Type: CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

ALTER TABLE ONLY immigration
    ADD CONSTRAINT immagration_pkey PRIMARY KEY (year);


--
-- Name: industry_pkey; Type: CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

ALTER TABLE ONLY industry
    ADD CONSTRAINT industry_pkey PRIMARY KEY (nacis_code);


--
-- Name: labors_pattern_pkey; Type: CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

ALTER TABLE ONLY labors_pattern
    ADD CONSTRAINT labors_pattern_pkey PRIMARY KEY (year, naics_code);


--
-- Name: time_pkey; Type: CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

ALTER TABLE ONLY "time"
    ADD CONSTRAINT time_pkey PRIMARY KEY (year);


--
-- Name: trading_pkey; Type: CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

ALTER TABLE ONLY trading
    ADD CONSTRAINT trading_pkey PRIMARY KEY (sampleid);


--
-- Name: fki_nacis; Type: INDEX; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE INDEX fki_nacis ON labors_pattern USING btree (naics_code);


--
-- Name: fki_trading_year; Type: INDEX; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE INDEX fki_trading_year ON trading USING btree (year);


--
-- Name: fki_year; Type: INDEX; Schema: public; Owner: todqwhtumtlwxu; Tablespace: 
--

CREATE INDEX fki_year ON labors_pattern USING btree (year);


--
-- Name: naics_code; Type: FK CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu
--

ALTER TABLE ONLY labors_pattern
    ADD CONSTRAINT naics_code FOREIGN KEY (naics_code) REFERENCES industry(nacis_code);


--
-- Name: trading_year; Type: FK CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu
--

ALTER TABLE ONLY trading
    ADD CONSTRAINT trading_year FOREIGN KEY (year) REFERENCES "time"(year);


--
-- Name: year; Type: FK CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu
--

ALTER TABLE ONLY exchange
    ADD CONSTRAINT year FOREIGN KEY (year) REFERENCES "time"(year);


--
-- Name: year; Type: FK CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu
--

ALTER TABLE ONLY immigration
    ADD CONSTRAINT year FOREIGN KEY (year) REFERENCES "time"(year);


--
-- Name: year; Type: FK CONSTRAINT; Schema: public; Owner: todqwhtumtlwxu
--

ALTER TABLE ONLY labors_pattern
    ADD CONSTRAINT year FOREIGN KEY (year) REFERENCES "time"(year);


--
-- Name: public; Type: ACL; Schema: -; Owner: todqwhtumtlwxu
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM todqwhtumtlwxu;
GRANT ALL ON SCHEMA public TO todqwhtumtlwxu;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

