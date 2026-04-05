<?php
include '../config/db.php';

$pending  = $conn->query("SELECT COUNT(*) as c FROM borrow_transactions WHERE status = 'Pending'")->fetch_assoc()['c'];
$active   = $conn->query("SELECT COUNT(*) as c FROM borrow_transactions WHERE status = 'Approved'")->fetch_assoc()['c'];
$overdue  = $conn->query("SELECT COUNT(*) as c FROM borrow_transactions WHERE status = 'Approved' AND due_date < NOW()")->fetch_assoc()['c'];
$total_eq = $conn->query("SELECT COUNT(*) as c FROM equipment")->fetch_assoc()['c'];
$avail_eq = $conn->query("SELECT COUNT(*) as c FROM equipment WHERE status = 'Available'")->fetch_assoc()['c'];
$damage   = $conn->query("SELECT COUNT(*) as c FROM damage_reports")->fetch_assoc()['c'];

echo json_encode([
    "success" => true,
    "data" => [
        "pending_requests"   => (int)$pending,
        "active_loans"       => (int)$active,
        "overdue_loans"      => (int)$overdue,
        "total_equipment"    => (int)$total_eq,
        "available_equipment"=> (int)$avail_eq,
        "damage_reports"     => (int)$damage,
    ]
]);

$conn->close();
?>