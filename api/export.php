<?php

declare(strict_types=1);

require __DIR__ . '/config.php';

$page = max(1, (int)($_GET['page'] ?? 1));
$pageSize = (int)($_GET['page_size'] ?? 250);
$pageSize = min(max($pageSize, 50), 500);
$offset = ($page - 1) * $pageSize;

$pdo = pdo();
$totalRows = (int)$pdo->query('SELECT COUNT(*) FROM orders')->fetchColumn();
$totalPages = max(1, (int)ceil($totalRows / $pageSize));

$sql = <<<SQL
SELECT
    o.id AS order_id,
    o.order_number,
    o.order_date,
    c.name AS customer_name,
    c.email AS customer_email,
    c.segment AS customer_segment,
    ci.name AS city,
    pr.name AS province,
    s.name AS sales_name,
    s.region AS sales_region,
    COUNT(oi.id) AS total_item_lines,
    SUM(oi.quantity) AS total_qty,
    SUM(oi.quantity * oi.unit_price) AS subtotal,
    o.discount_amount,
    o.shipping_cost,
    (SUM(oi.quantity * oi.unit_price) - o.discount_amount + o.shipping_cost) AS grand_total,
    GROUP_CONCAT(DISTINCT p.name ORDER BY p.name SEPARATOR ', ') AS product_names,
    GROUP_CONCAT(DISTINCT cat.name ORDER BY cat.name SEPARATOR ', ') AS categories
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN cities ci ON ci.id = c.city_id
JOIN provinces pr ON pr.id = ci.province_id
JOIN sales_reps s ON s.id = o.sales_rep_id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
JOIN categories cat ON cat.id = p.category_id
GROUP BY
    o.id,
    o.order_number,
    o.order_date,
    c.name,
    c.email,
    c.segment,
    ci.name,
    pr.name,
    s.name,
    s.region,
    o.discount_amount,
    o.shipping_cost
ORDER BY o.order_date DESC, o.id DESC
LIMIT :limit OFFSET :offset
SQL;

$stmt = $pdo->prepare($sql);
$stmt->bindValue(':limit', $pageSize, PDO::PARAM_INT);
$stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$stmt->execute();

json_response([
    'data' => $stmt->fetchAll(),
    'meta' => [
        'page' => $page,
        'page_size' => $pageSize,
        'total_rows' => $totalRows,
        'total_pages' => $totalPages,
    ],
]);
