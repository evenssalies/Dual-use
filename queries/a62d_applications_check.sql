-- Contrôle de la requête a62d_applications_by_year.sql.
-- Renvoie les lignes incohérentes : total fractionnaire <= 0, ou supérieur au nombre de demandes de la technologie et de l'année.
-- Une requête vide est le résultat attendu.
-- Mêmes filtres et même regroupement par pct_number que la requête principale.

WITH demandes AS (
  SELECT
    pct_number,
    tech,
    MIN(DIV(priority_date, 10000)) AS year,
    ARRAY_AGG(DISTINCT a.country_code IGNORE NULLS) AS pays
  FROM `patents-public-data.patents.publications`, UNNEST(['F41', 'F42']) AS tech, UNNEST(assignee_harmonized) AS a
  WHERE
    pct_number IS NOT NULL
    AND TRIM(pct_number) != ''
    AND kind_code LIKE 'A%'
    AND priority_date BETWEEN 20000101 AND 20211231
    AND a.country_code != ''
    AND (
      EXISTS(SELECT 1 FROM UNNEST(cpc) c WHERE STARTS_WITH(c.code, tech))
      OR EXISTS(SELECT 1 FROM UNNEST(ipc) i WHERE STARTS_WITH(i.code, tech)))
  GROUP BY pct_number, tech
),

fractions AS (
  SELECT
    tech,
    pays_inclus AS country_code,
    year,
    1 / ARRAY_LENGTH(pays) AS fraction
  FROM demandes, UNNEST(pays) AS pays_inclus
  WHERE pays_inclus IN ('US', 'CN', 'FR', 'DE', 'ES', 'IT')
),

resultats AS (
  SELECT
    tech,
    country_code,
    year,
    SUM(fraction) AS applications
  FROM fractions
  GROUP BY tech, country_code, year
),

totaux AS (
  SELECT
    tech,
    year,
    COUNT(*) AS demandes_annee
  FROM demandes
  GROUP BY tech, year
)

SELECT
  r.tech,
  r.country_code,
  r.year,
  r.applications,
  t.demandes_annee
FROM resultats AS r
JOIN totaux AS t
  ON r.tech = t.tech AND r.year = t.year
WHERE r.applications <= 0
  OR r.applications > t.demandes_annee
ORDER BY r.tech, r.country_code, r.year;
