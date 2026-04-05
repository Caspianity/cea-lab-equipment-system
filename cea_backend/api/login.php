<?php
include '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

$identifier = trim($data['identifier'] ?? '');
$password   = trim($data['password'] ?? '');
$role       = trim($data['role'] ?? 'student'); // 'student' or 'staff'

if (empty($identifier) || empty($password)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "All fields are required."]);
    exit();
}

if ($role === 'student') {
    // Students login with student_number
    $stmt = $conn->prepare("SELECT student_id, name, student_number, course, year_level, password FROM students WHERE student_number = ?");
    $stmt->bind_param("s", $identifier);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        http_response_code(401);
        echo json_encode(["success" => false, "message" => "Student ID not found."]);
        exit();
    }

    $user = $result->fetch_assoc();

    if (!password_verify($password, $user['password'])) {
        http_response_code(401);
        echo json_encode(["success" => false, "message" => "Incorrect password."]);
        exit();
    }

    unset($user['password']);
    echo json_encode([
        "success" => true,
        "role"    => "student",
        "user"    => $user
    ]);

} else {
    // Staff login with email
    $stmt = $conn->prepare("SELECT staff_id, name, email, role, password FROM staff WHERE email = ?");
    $stmt->bind_param("s", $identifier);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        http_response_code(401);
        echo json_encode(["success" => false, "message" => "Email not found."]);
        exit();
    }

    $user = $result->fetch_assoc();

    if (!password_verify($password, $user['password'])) {
        http_response_code(401);
        echo json_encode(["success" => false, "message" => "Incorrect password."]);
        exit();
    }

    unset($user['password']);
    echo json_encode([
        "success" => true,
        "role"    => "staff",
        "user"    => $user
    ]);
}

$stmt->close();
$conn->close();
?>