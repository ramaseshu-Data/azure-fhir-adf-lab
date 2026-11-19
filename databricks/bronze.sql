CREATE OR REFRESH STREAMING TABLE wiki_edits_bronze_v2 AS
SELECT
  get_json_object(CAST(value AS STRING), '$.rcid')  AS edit_id,
  get_json_object(CAST(value AS STRING), '$.title') AS page_title,
  partition AS hub_partition,
  offset AS hub_offset,
  CAST(value AS STRING) AS raw_json
FROM STREAM read_kafka(
  bootstrapServers  => 'eh-ramaseshu-wiki.servicebus.windows.net:9093',
  subscribe         => 'wiki-events',
  serviceCredential => 'wiki_events_service',
  startingOffsets   => 'earliest'
);
