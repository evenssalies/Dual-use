-- Applications classified in IPC or CPC A62D, US and CN, by filing year (2000-2021).
-- Source: Google Patents Public Data on BigQuery. Not yet run: check the schema and the bytes processed first.
-- Counts publications of kind A (applications), so utility models (U) and grants (B) are excluded.
-- For US 2000, pre-grant publications are incomplete (published applications start from 2001).

SELECT
  country_code,
  DIV(filing_date, 10000) AS year,
  COUNT(DISTINCT publication_number) AS applications
FROM `patents-public-data.patents.publications`
WHERE country_code IN ('US', 'CN')
  AND kind_code LIKE 'A%'
  AND filing_date BETWEEN 20000101 AND 20211231
  AND (
    EXISTS (SELECT 1 FROM UNNEST(cpc) c WHERE STARTS_WITH(c.code, 'A62D'))
    OR EXISTS (SELECT 1 FROM UNNEST(ipc) i WHERE STARTS_WITH(i.code, 'A62D'))
  )
GROUP BY country_code, year
ORDER BY country_code, year;
