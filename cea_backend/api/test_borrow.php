<?php
include '../config/db.php';

// Test: insert a simple borrow transaction
$student_id   = 1;
$equipment_id = 1;
$borrow_date  = date('Y-m-d H:i:s');
$due_date     = date('Y-m-d') . ' 17:00:00';

$stmt = $conn->prepare("INSERT INTO borrow_transactions 
    (student_id, equipment_id, borrow_date, due_date, status) 
    VALUES (?, ?, ?, ?, 'Pending')");
$stmt->bind_param("iiss", $student_id, $equipment_id, $borrow_date, $due_date);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Test borrow inserted!", "id" => $stmt->insert_id]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}
?>