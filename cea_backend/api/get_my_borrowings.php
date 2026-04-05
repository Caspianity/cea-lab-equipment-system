<?php
include '../config/db.php';

$student_id     = intval($_GET['student_id'] ?? 0);
$student_number = trim($_GET['student_number'] ?? '');

if ($student_id === 0 && empty($student_number)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "student_id or student_number required."]);
    exit();
}

if ($student_id > 0) {
    $stmt = $conn->prepare("
        SELECT bt.*, e.equipment_name, e.category, e.qr_code
        FROM borrow_transactions bt
        JOIN equipment e ON bt.equipment_id = e.equipment_id
        WHERE bt.student_id = ?
        ORDER BY bt.borrow_date DESC
    ");
    $stmt->bind_param("i", $student_id);
} else {
    $stmt = $conn->prepare("
        SELECT bt.*, e.equipment_name, e.category, e.qr_code
        FROM borrow_transactions bt
        JOIN equipment e ON bt.equipment_id = e.equipment_id
        WHERE bt.student_number = ?
        ORDER BY bt.borrow_date DESC
    ");
    $stmt->bind_param("s", $student_number);
}

$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);

$stmt->close();
$conn->close();
?>