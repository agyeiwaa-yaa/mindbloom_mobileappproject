<?php

require_once __DIR__ . '/helpers.php';

try {
    $pdo = mindbloom_db();
    ensure_tables_exist($pdo);
    $body = request_body();
    $userId = (string) field($body, 'user_id', '');
    $displayName = (string) field($body, 'display_name', 'MindBloom User');

    if ($userId === '') {
        json_response(false, null, 'user_id is required', 422);
    }

    upsert_user($pdo, $userId, $displayName);
    json_response(true, ['user_id' => $userId]);
} catch (Throwable $error) {
    json_response(false, null, $error->getMessage(), 500);
}
