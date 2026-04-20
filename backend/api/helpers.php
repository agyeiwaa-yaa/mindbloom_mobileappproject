<?php

require_once __DIR__ . '/db.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

function json_response(bool $success, $data = null, ?string $message = null, int $status = 200): void
{
    http_response_code($status);
    echo json_encode([
        'success' => $success,
        'data' => $data,
        'message' => $message,
    ]);
    exit;
}

function request_body(): array
{
    $raw = file_get_contents('php://input');
    if ($raw === false || trim($raw) === '') {
      return [];
    }

    $decoded = json_decode($raw, true);
    return is_array($decoded) ? $decoded : [];
}

function field(array $body, string $key, $default = null)
{
    if (array_key_exists($key, $body)) {
        return $body[$key];
    }

    if (array_key_exists($key, $_POST)) {
        return $_POST[$key];
    }

    return $default;
}

function ensure_tables_exist(PDO $pdo): void
{
    $schema = file_get_contents(__DIR__ . '/../sql/schema.sql');
    if ($schema !== false) {
        $pdo->exec($schema);
    }
}

function upsert_user(PDO $pdo, string $userId, string $displayName): void
{
    $stmt = $pdo->prepare(
        'INSERT INTO users (id, full_name, created_at)
         VALUES (:id, :full_name, NOW())
         ON DUPLICATE KEY UPDATE full_name = VALUES(full_name)'
    );
    $stmt->execute([
        ':id' => $userId,
        ':full_name' => $displayName,
    ]);
}

function upload_public_url(string $fileName): string
{
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $base = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
    return sprintf(
        '%s://%s%s/../uploads/%s',
        $scheme,
        $_SERVER['HTTP_HOST'],
        $base,
        $fileName
    );
}
