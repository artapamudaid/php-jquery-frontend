<?php

declare(strict_types=1);

require __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_response(['message' => 'Method not allowed'], 405);
}

$payload = read_json_body();
$rows = $payload['rows'] ?? [];

if (!is_array($rows) || count($rows) > 500) {
    json_response(['message' => 'Batch harus berisi maksimal 500 baris.'], 422);
}

$pdo = pdo();
$stmt = $pdo->prepare(
    'INSERT INTO imported_customers
        (external_id, name, email, phone, city, registered_at)
     VALUES
        (:external_id, :name, :email, :phone, :city, :registered_at)
     ON DUPLICATE KEY UPDATE
        name = VALUES(name),
        email = VALUES(email),
        phone = VALUES(phone),
        city = VALUES(city),
        registered_at = VALUES(registered_at)'
);

$inserted = 0;
$skipped = 0;
$pdo->beginTransaction();

try {
    foreach ($rows as $row) {
        $externalId = trim((string)($row['external_id'] ?? ''));
        $name = trim((string)($row['name'] ?? ''));
        $email = trim((string)($row['email'] ?? ''));

        if ($externalId === '' || $name === '' || $email === '') {
            $skipped++;
            continue;
        }

        $stmt->execute([
            ':external_id' => $externalId,
            ':name' => $name,
            ':email' => $email,
            ':phone' => trim((string)($row['phone'] ?? '')),
            ':city' => trim((string)($row['city'] ?? '')),
            ':registered_at' => normalize_date((string)($row['registered_at'] ?? '')),
        ]);

        $inserted++;
    }

    $pdo->commit();
} catch (Throwable $exception) {
    $pdo->rollBack();
    json_response(['message' => $exception->getMessage()], 500);
}

json_response([
    'message' => 'Batch processed',
    'inserted' => $inserted,
    'skipped' => $skipped,
    'batch_index' => (int)($payload['batch_index'] ?? 0),
    'total_batches' => (int)($payload['total_batches'] ?? 0),
]);

function normalize_date(string $value): ?string
{
    if (trim($value) === '') {
        return null;
    }

    $timestamp = strtotime($value);

    return $timestamp === false ? null : date('Y-m-d', $timestamp);
}
