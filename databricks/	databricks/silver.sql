CREATE OR REFRESH MATERIALIZED VIEW wiki_edits_silver AS
SELECT
  edit_id,
  trim(page_title) AS page_title,
  try_cast(get_json_object(raw_json, '$.timestamp') AS TIMESTAMP) AS edit_time
FROM wiki_edits_bronze_v2
WHERE edit_id IS NOT NULL
  AND trim(page_title) <> ''
QUALIFY row_number() OVER (
  PARTITION BY edit_id
  ORDER BY hub_partition, hub_offset
) = 1;
