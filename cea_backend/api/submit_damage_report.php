<?php
include '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

$transaction_id = intval($data['transaction_id'] ?? 0);
$equipment_id   = intval($data['equipment_id'] ?? 0);
$student_id     = intval($data['student_id'] ?? 0);
$description    = trim($data['description'] ?? '');

if (empty($description) || $equipment_id === 0) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Equipment ID and description are required."]);
    exit();
}

$stmt = $conn->prepare("INSERT INTO damage_reports (transaction_id, equipment_id, student_id, description) VALUES (?, ?, ?, ?)");
$stmt->bind_param("iiis", $transaction_id, $equipment_id, $student_id, $description);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Damage report submitted successfully.", "report_id" => $stmt->insert_id]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to submit report: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>