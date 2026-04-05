<?php
include '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

$student_id = intval($data['student_id'] ?? 0);
$name       = trim($data['name']       ?? '');
$course     = trim($data['course']     ?? '');
$year_level = intval($data['year_level'] ?? 0);

if ($student_id === 0 || empty($name)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Student ID and name are required."]);
    exit();
}

$stmt = $conn->prepare("UPDATE students SET name = ?, course = ?, year_level = ? WHERE student_id = ?");
$stmt->bind_param("ssii", $name, $course, $year_level, $student_id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Profile updated successfully."]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to update: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>