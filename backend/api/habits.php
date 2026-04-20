<?php

require_once __DIR__ . '/helpers.php';

try {
    $pdo = mindbloom_db();
    ensure_tables_exist($pdo);
    $body = request_body();

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $userId = $_GET['user_id'] ?? '';
        $habitStmt = $pdo->prepare('SELECT id, name, icon_key, color_value, target_per_week, reminder_enabled, reminder_hour, reminder_minute, created_at, archived FROM habits WHERE user_id = :user_id AND archived = 0 ORDER BY created_at DESC');
        $habitStmt->execute([':user_id' => $userId]);
        $habits = $habitStmt->fetchAll();

        $completionStmt = $pdo->prepare(
            'SELECT hc.habit_id, hc.completed_on
             FROM habit_completions hc
             INNER JOIN habits h ON h.id = hc.habit_id
             WHERE h.user_id = :user_id'
        );
        $completionStmt->execute([':user_id' => $userId]);
        $completions = [];
        foreach ($completionStmt->fetchAll() as $row) {
            $habitId = $row['habit_id'];
            if (!array_key_exists($habitId, $completions)) {
                $completions[$habitId] = [];
            }
            $completions[$habitId][] = $row['completed_on'];
        }

        json_response(true, [
            'habits' => $habits,
            'completions' => $completions,
        ]);
    }

    $action = (string) field($body, 'action', 'save');
    $userId = (string) field($body, 'user_id', '');
    if ($userId === '') {
        json_response(false, null, 'user_id is required', 422);
    }

    if ($action === 'archive') {
        $stmt = $pdo->prepare('UPDATE habits SET archived = 1 WHERE id = :id AND user_id = :user_id');
        $stmt->execute([
            ':id' => (string) field($body, 'id', ''),
            ':user_id' => $userId,
        ]);
        json_response(true, true);
    }

    if ($action === 'toggle_completion') {
        $habitId = (string) field($body, 'habit_id', '');
        $completedOn = (string) field($body, 'completed_on', '');
        $check = $pdo->prepare('SELECT id FROM habit_completions WHERE habit_id = :habit_id AND completed_on = :completed_on LIMIT 1');
        $check->execute([
            ':habit_id' => $habitId,
            ':completed_on' => $completedOn,
        ]);
        $existing = $check->fetch();
        if ($existing) {
            $delete = $pdo->prepare('DELETE FROM habit_completions WHERE habit_id = :habit_id AND completed_on = :completed_on');
            $delete->execute([
                ':habit_id' => $habitId,
                ':completed_on' => $completedOn,
            ]);
        } else {
            $insert = $pdo->prepare('INSERT INTO habit_completions (habit_id, completed_on) VALUES (:habit_id, :completed_on)');
            $insert->execute([
                ':habit_id' => $habitId,
                ':completed_on' => $completedOn,
            ]);
        }
        json_response(true, true);
    }

    $data = [
        ':id' => (string) field($body, 'id', ''),
        ':user_id' => $userId,
        ':name' => (string) field($body, 'name', ''),
        ':icon_key' => (string) field($body, 'icon_key', 'water'),
        ':color_value' => (int) field($body, 'color_value', 0),
        ':target_per_week' => (int) field($body, 'target_per_week', 7),
        ':reminder_enabled' => field($body, 'reminder_enabled') ? 1 : 0,
        ':reminder_hour' => field($body, 'reminder_hour'),
        ':reminder_minute' => field($body, 'reminder_minute'),
        ':created_at' => (string) field($body, 'created_at', date(DATE_ATOM)),
        ':archived' => field($body, 'archived') ? 1 : 0,
    ];

    $stmt = $pdo->prepare(
        'INSERT INTO habits (id, user_id, name, icon_key, color_value, target_per_week, reminder_enabled, reminder_hour, reminder_minute, created_at, archived)
         VALUES (:id, :user_id, :name, :icon_key, :color_value, :target_per_week, :reminder_enabled, :reminder_hour, :reminder_minute, :created_at, :archived)
         ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            icon_key = VALUES(icon_key),
            color_value = VALUES(color_value),
            target_per_week = VALUES(target_per_week),
            reminder_enabled = VALUES(reminder_enabled),
            reminder_hour = VALUES(reminder_hour),
            reminder_minute = VALUES(reminder_minute),
            created_at = VALUES(created_at),
            archived = VALUES(archived)'
    );
    $stmt->execute($data);

    $fetch = $pdo->prepare('SELECT id, name, icon_key, color_value, target_per_week, reminder_enabled, reminder_hour, reminder_minute, created_at, archived FROM habits WHERE id = :id AND user_id = :user_id LIMIT 1');
    $fetch->execute([
        ':id' => $data[':id'],
        ':user_id' => $userId,
    ]);
    json_response(true, $fetch->fetch());
} catch (Throwable $error) {
    json_response(false, null, $error->getMessage(), 500);
}
