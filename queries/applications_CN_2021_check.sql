-- Contrôle : total fractionnaire des demandes PCT de type A déposées par des déposants chinois (CN),
-- année de priorité 2021, sans filtre sur les codes IPC (toutes technologies).
-- Même logique que dual_use_applications_by_year.sql, sans la liste de codes.
-- Source : Google Patents Public Data sur BigQuery.
-- Crédit fractionné : chaque demande vaut 1/n, n étant le nombre de pays distincts de ses déposants, tous pays confondus.

WITH demandes AS (
  -- Une ligne par demande PCT (pct_number).
  SELECT
    -- Numéro de la demande PCT : c'est l'unité comptée.
    pct_number,
    -- Année de la date de priorité la plus ancienne de la demande (AAAAMMJJ divisé par 10000 donne AAAA).
    MIN(DIV(priority_date, 10000)) AS year,
    -- Liste des pays distincts des déposants (sans NULL), tous pays confondus.
    ARRAY_AGG(DISTINCT a.country_code IGNORE NULLS) AS pays
  -- Une ligne par publication et par déposant : UNNEST éclate la liste assignee_harmonized.
  FROM `patents-public-data.patents.publications`, UNNEST(assignee_harmonized) AS a
  WHERE
    -- Garde seulement les publications avec un numéro PCT renseigné.
    pct_number IS NOT NULL
    AND TRIM(pct_number) != ''
    -- Garde seulement les publications de type A (demandes, par ex. A1, A2).
    AND kind_code LIKE 'A%'
    -- Garde seulement les publications dont la date de priorité est en 2021.
    AND priority_date BETWEEN 20210101 AND 20261110
    -- Ignore les déposants sans code pays.
    AND a.country_code != ''
  -- Regroupe les publications par demande PCT : une demande n'est comptée qu'une fois.
  GROUP BY pct_number
)

SELECT
  -- Année de priorité, affichée à côté du total.
  year,
  -- Somme des crédits fractionnaires des demandes retenues pour la Chine, par année.
  SUM(1 / ARRAY_LENGTH(pays)) AS applications_cn_2021
-- Une ligne par pays de la liste, puis garde seulement CN et les années à partir de 2021.
FROM demandes, UNNEST(pays) AS pays_inclus
WHERE pays_inclus = 'CN'
  AND year >= 2021
  GROUP BY year ORDER BY year;