<?php
include '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

$first_name     = trim($data['first_name'] ?? '');
$last_name      = trim($data['last_name'] ?? '');
$email          = trim($data['email'] ?? '');
$student_number = trim($data['student_number'] ?? '');
$course         = trim($data['course'] ?? '');
$year_level     = intval($data['year_level'] ?? 0);
$password       = trim($data['password'] ?? '');

// Basic validation
if (empty($first_name) || empty($last_name) || empty($email) || empty($student_number) || empty($password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "All required fields must be filled."]);
    exit();
}

// Check if student number already exists
$check = $conn->prepare("SELECT student_id FROM students WHERE student_number = ?");
$check->bind_param("s", $student_number);
$check->execute();
$check->store_result();
if ($check->num_rows > 0) {
    http_response_code(409);
    echo json_encode(["success" => false, "message" => "Student ID already registered."]);
    exit();
}
$check->close();

// Check if email already exists
$check2 = $conn->prepare("SELECT student_id FROM students WHERE email = ?");
$check2->bind_param("s", $email);
$check2->execute();
$check2->store_result();
if ($check2->num_rows > 0) {
    http_response_code(409);
    echo json_encode(["success" => false, "message" => "Email already registered."]);
    exit();
}
$check2->close();

// Hash password
$hashed = password_hash($password, PASSWORD_BCRYPT);
$name   = $first_name . ' ' . $last_name;

$stmt = $conn->prepare("INSERT INTO students (name, email, student_number, course, year_level, password) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssis", $name, $email, $student_number, $course, $year_level, $hashed);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Account created successfully.", "student_id" => $stmt->insert_id]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Registration failed: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>