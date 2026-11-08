-- Applications classified in IPC or CPC F41 (weapons) or F42 (ammunition, blasting), US and CN, by filing year (2000-2021).
-- Source: Google Patents Public Data on BigQuery. Not yet run: check the schema and the bytes processed first.
-- Counts publications of kind A (applications), so utility models (U) and grants (B) are excluded.
-- A publication classified in both F41 and F42 is counted once under each technology.
-- For US 2000, pre-grant publications are incomplete (published applications start from 2001).
-- Applications in US and CN associated with a PCT filing (pct_number is present).
-- Classified in IPC or CPC F41 (weapons) or F42 (ammunition, blasting).
-- Filing year: 2000-2021.

SELECT
  tech,
  country_code,
  DIV(filing_date, 10000) AS year,
  COUNT(DISTINCT publication_number) AS applications
FROM `patents-public-data.patents.publications`, UNNEST(['F41', 'F42']) AS tech
WHERE
  country_code IN ('US', 'CN')
  AND pct_number != ''
  AND kind_code LIKE 'A%'
  AND filing_date BETWEEN 20000101 AND 20211231
  AND (
    EXISTS(SELECT 1 FROM UNNEST(cpc) c WHERE STARTS_WITH(c.code, tech))
    OR EXISTS(SELECT 1 FROM UNNEST(ipc) i WHERE STARTS_WITH(i.code, tech)))
GROUP BY tech, country_code, year
ORDER BY tech, country_code, year;
