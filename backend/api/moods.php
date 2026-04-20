<?php

require_once __DIR__ . '/helpers.php';

try {
    $pdo = mindbloom_db();
    ensure_tables_exist($pdo);
    $body = request_body();

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $userId = $_GET['user_id'] ?? '';
        $stmt = $pdo->prepare('SELECT id, mood, score, note, created_at, location_name, latitude, longitude FROM mood_entries WHERE user_id = :user_id ORDER BY created_at DESC');
        $stmt->execute([':user_id' => $userId]);
        json_response(true, $stmt->fetchAll());
    }

    $action = (string) field($body, 'action', 'save');
    $userId = (string) field($body, 'user_id', '');
    if ($userId === '') {
        json_response(false, null, 'user_id is required', 422);
    }

    if ($action === 'delete') {
        $stmt = $pdo->prepare('DELETE FROM mood_entries WHERE id = :id AND user_id = :user_id');
        $stmt->execute([
            ':id' => (string) field($body, 'id', ''),
            ':user_id' => $userId,
        ]);
        json_response(true, true);
    }

    $data = [
        ':id' => (string) field($body, 'id', ''),
        ':user_id' => $userId,
        ':mood' => (string) field($body, 'mood', ''),
        ':score' => (int) field($body, 'score', 0),
        ':note' => field($body, 'note'),
        ':created_at' => (string) field($body, 'created_at', date(DATE_ATOM)),
        ':location_name' => field($body, 'location_name'),
        ':latitude' => field($body, 'latitude'),
        ':longitude' => field($body, 'longitude'),
    ];

    $stmt = $pdo->prepare(
        'INSERT INTO mood_entries (id, user_id, mood, score, note, created_at, location_name, latitude, longitude)
         VALUES (:id, :user_id, :mood, :score, :note, :created_at, :location_name, :latitude, :longitude)
         ON DUPLICATE KEY UPDATE
            mood = VALUES(mood),
            score = VALUES(score),
            note = VALUES(note),
            created_at = VALUES(created_at),
            location_name = VALUES(location_name),
            latitude = VALUES(latitude),
            longitude = VALUES(longitude)'
    );
    $stmt->execute($data);

    $fetch = $pdo->prepare('SELECT id, mood, score, note, created_at, location_name, latitude, longitude FROM mood_entries WHERE id = :id AND user_id = :user_id LIMIT 1');
    $fetch->execute([
        ':id' => $data[':id'],
        ':user_id' => $userId,
    ]);
    json_response(true, $fetch->fetch());
} catch (Throwable $error) {
    json_response(false, null, $error->getMessage(), 500);
}
