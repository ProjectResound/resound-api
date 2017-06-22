SELECT
  audios.id AS id,
  audios.title AS title,
  audios.filename AS filename,
  audios.tags AS tags,
  audios.duration as duration,
  audios.created_at as created_at,
  users.nickname AS uploader_nickname
FROM audios
JOIN users ON audios.uploader_id = users.uid
