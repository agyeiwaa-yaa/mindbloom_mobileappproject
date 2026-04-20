<?php

require_once __DIR__ . '/helpers.php';

try {
    $pdo = mindbloom_db();
    ensure_tables_exist($pdo);
    json_response(true, ['status' => 'ok']);
} catch (Throwable $error) {
    json_response(false, null, $error->getMessage(), 500);
}
