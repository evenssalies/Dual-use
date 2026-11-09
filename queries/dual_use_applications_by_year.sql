-- Demandes de brevets (kind A) issues d'une procédure PCT, classées dans l'un des dix-neuf codes IPC retenus.
-- Codes : classes F41, F42, B63G ; groupes B21D51/54, B21K21/04, B21K21/06, B21K21/14, B60R7/14, B64D1/04,
-- B64D1/06, B64D7/, E04H9/04, E04H9/08, E04H9/12, E06B5/10, G01S1/42, G01S19/18, G06G7/80 ; sous-groupe A62D101/02.
-- Correspondance par préfixe, après suppression des espaces du code IPC. "B64D7/" avec la barre finale ne couvre pas B64D71, etc.
-- Pays inclus : US, CN, FR, DE, ES, IT.
-- Période : année de la date de priorité la plus ancienne (priority_date) : 2000 - 2021.
-- Source : Google Patents Public Data sur BigQuery.
-- Unité : une demande PCT (pct_number), comptée une seule fois même si elle porte plusieurs codes de la liste.
-- Crédit fractionné : chaque demande vaut 1/n, n étant le nombre de pays distincts des déposants, tous pays confondus ;
-- seuls les pays inclus sont retournés. Les codes CPC ne sont pas pris en compte.
-- Résultat par pays et par année, sans distinction de technologie.

WITH codes AS (
  SELECT p FROM UNNEST([
    'F41', 'F42', 'B63G',
    'B21D51/54', 'B21K21/04', 'B21K21/06', 'B21K21/14',
    'B60R7/14', 'B64D1/04', 'B64D1/06', 'B64D7/',
    'E04H9/04', 'E04H9/08', 'E04H9/12', 'E06B5/10',
    'G01S1/42', 'G01S19/18', 'G06G7/80', 'A62D101/02'
  ]) AS p
),

demandes AS (
  SELECT
    pct_number,
    MIN(DIV(priority_date, 10000)) AS year,
    ARRAY_AGG(DISTINCT a.country_code IGNORE NULLS) AS pays
  FROM `patents-public-data.patents.publications`, UNNEST(assignee_harmonized) AS a
  WHERE
    pct_number IS NOT NULL
    AND TRIM(pct_number) != ''
    AND kind_code LIKE 'A%'
    AND priority_date BETWEEN 20000101 AND 20211231
    AND a.country_code != ''
    AND EXISTS(
      SELECT 1 FROM UNNEST(ipc) i, codes
      WHERE STARTS_WITH(REGEXP_REPLACE(i.code, r'\s+', ''), codes.p))
  GROUP BY pct_number
)

SELECT
  pays_inclus AS country_code,
  year,
  SUM(1 / ARRAY_LENGTH(pays)) AS applications
FROM demandes, UNNEST(pays) AS pays_inclus
WHERE pays_inclus IN ('US', 'CN', 'FR', 'DE', 'ES', 'IT')
GROUP BY country_code, year
ORDER BY country_code, year;
