-- Analyse des demandes de brevets (Kind A) issues d'une procédure PCT.
-- Pays inclus : US, CN, FR, DE, ES, IT.
-- Technologies : Armes (F41) et Munitions/Explosifs (F42) selon les classifications IPC/CPC.
-- Période : année de la date de priorité la plus ancienne (priority_date) : 2000 - 2021.
-- Source : Google Patents Public Data sur BigQuery.
-- Unité : une demande PCT (pct_number). Les pays des déposants de toutes ses publications sont réunis,
-- chaque pays n'étant compté qu'une fois.
-- Crédit fractionné : chaque demande vaut 1/n, n étant le nombre de pays distincts des déposants, tous pays confondus ;
-- seuls les pays inclus sont retournés.
-- Une demande sans pays de déposant renseigné n'apparaît pas dans les résultats.
-- Les pays d'enregistrement de la famille de brevets (family_id) ne sont pas pris en compte.

WITH demandes AS (
  SELECT
    pct_number,
    tech,
    MIN(DIV(priority_date, 10000)) AS year,
    ARRAY_AGG(DISTINCT a.country_code IGNORE NULLS) AS pays
  FROM `patents-public-data.patents.publications`, UNNEST(['F41', 'F42']) AS tech, UNNEST(assignee_harmonized) AS a
  WHERE
    pct_number != ''
    AND kind_code LIKE 'A%'
    AND priority_date BETWEEN 20000101 AND 20211231
    AND a.country_code != ''
    AND (
      EXISTS(SELECT 1 FROM UNNEST(cpc) c WHERE STARTS_WITH(c.code, tech))
      OR EXISTS(SELECT 1 FROM UNNEST(ipc) i WHERE STARTS_WITH(i.code, tech)))
  GROUP BY pct_number, tech
)

SELECT
  tech,
  pays_inclus AS country_code,
  year,
  SUM(1 / ARRAY_LENGTH(pays)) AS applications
FROM demandes, UNNEST(pays) AS pays_inclus
WHERE pays_inclus IN ('US', 'CN', 'FR', 'DE', 'ES', 'IT')
GROUP BY tech, country_code, year
ORDER BY tech, country_code, year;
