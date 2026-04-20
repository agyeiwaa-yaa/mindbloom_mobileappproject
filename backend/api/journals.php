<?php

require_once __DIR__ . '/helpers.php';

try {
    $pdo = mindbloom_db();
    ensure_tables_exist($pdo);
    $body = request_body();

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $userId = $_GET['user_id'] ?? '';
        $stmt = $pdo->prepare('SELECT id, title, content, mood, image_path, created_at, location_name, latitude, longitude FROM journal_entries WHERE user_id = :user_id ORDER BY created_at DESC');
        $stmt->execute([':user_id' => $userId]);
        json_response(true, $stmt->fetchAll());
    }

    $action = (string) field($body, 'action', 'save');
    $userId = (string) field($body, 'user_id', '');
    if ($userId === '') {
        json_response(false, null, 'user_id is required', 422);
    }

    if ($action === 'delete') {
        $stmt = $pdo->prepare('DELETE FROM journal_entries WHERE id = :id AND user_id = :user_id');
        $stmt->execute([
            ':id' => (string) field($body, 'id', ''),
            ':user_id' => $userId,
        ]);
        json_response(true, true);
    }

    $imagePath = field($body, 'image_path');
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
        $config = mindbloom_config();
        $uploadDir = $config['upload_dir'];
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0775, true);
        }
        $extension = pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
        $fileName = 'journal_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $extension;
        $destination = rtrim($uploadDir, '/') . '/' . $fileName;
        move_uploaded_file($_FILES['image']['tmp_name'], $destination);
        $imagePath = upload_public_url($fileName);
    } elseif (($existing = field($body, 'existing_image_path', '')) !== '') {
        $imagePath = $existing;
    }

    $data = [
        ':id' => (string) field($body, 'id', ''),
        ':user_id' => $userId,
        ':title' => (string) field($body, 'title', ''),
        ':content' => (string) field($body, 'content', ''),
        ':mood' => field($body, 'mood'),
        ':image_path' => $imagePath,
        ':created_at' => (string) field($body, 'created_at', date(DATE_ATOM)),
        ':location_name' => field($body, 'location_name'),
        ':latitude' => field($body, 'latitude'),
        ':longitude' => field($body, 'longitude'),
    ];

    $stmt = $pdo->prepare(
        'INSERT INTO journal_entries (id, user_id, title, content, mood, image_path, created_at, location_name, latitude, longitude)
         VALUES (:id, :user_id, :title, :content, :mood, :image_path, :created_at, :location_name, :latitude, :longitude)
         ON DUPLICATE KEY UPDATE
            title = VALUES(title),
            content = VALUES(content),
            mood = VALUES(mood),
            image_path = VALUES(image_path),
            created_at = VALUES(created_at),
            location_name = VALUES(location_name),
            latitude = VALUES(latitude),
            longitude = VALUES(longitude)'
    );
    $stmt->execute($data);

    $fetch = $pdo->prepare('SELECT id, title, content, mood, image_path, created_at, location_name, latitude, longitude FROM journal_entries WHERE id = :id AND user_id = :user_id LIMIT 1');
    $fetch->execute([
        ':id' => $data[':id'],
        ':user_id' => $userId,
    ]);
    json_response(true, $fetch->fetch());
} catch (Throwable $error) {
    json_response(false, null, $error->getMessage(), 500);
}
