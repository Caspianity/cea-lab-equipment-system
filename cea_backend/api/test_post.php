<?php
error_reporting(0);
ini_set('display_errors', 0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include '../config/db.php';

// Hard-coded test insert
$student_id    = 1;
$equipment_id  = 1;
$borrower_name = 'Test Student';
$student_number= '2024-00001';
$subject       = 'Test Subject';
$quantity      = 1;
$borrow_date   = date('Y-m-d H:i:s');
$due_date      = date('Y-m-d') . ' 17:00:00';
$purpose       = 'Test purpose';

$stmt = $conn->prepare("INSERT INTO borrow_transactions 
    (student_id, equipment_id, borrower_name, student_number, subject, quantity, borrow_date, due_date, purpose, status) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending')");

if (!$stmt) {
    echo json_encode(["success" => false, "step" => "prepare", "error" => $conn->error]);
    exit();
}

$stmt->bind_param("iisssiiss",
    $student_id, $equipment_id,
    $borrower_name, $student_number,
    $subject, $quantity,
    $borrow_date, $due_date, $purpose);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Inserted!", "id" => $stmt->insert_id]);
} else {
    echo json_encode(["success" => false, "step" => "execute", "error" => $stmt->error]);
}
?>