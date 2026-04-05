<?php
error_reporting(0);
ini_set('display_errors', 0);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include '../config/db.php';

// Read from $_POST (form-encoded) OR php://input (JSON) — whichever has data
$data = $_POST;
if (empty($data)) {
    $raw  = file_get_contents("php://input");
    $data = json_decode($raw, true) ?? [];
}

$equipment_id  = intval($data['equipment_id']  ?? 0);
$student_id    = intval($data['student_id']    ?? 0);
$borrower_name = trim($data['borrower_name']   ?? '');
$student_number= trim($data['student_number']  ?? '');
$subject       = trim($data['subject']         ?? '');
$quantity      = intval($data['quantity']      ?? 1);
$purpose       = trim($data['purpose']         ?? '');
$borrow_date   = date('Y-m-d H:i:s');
$due_date      = date('Y-m-d') . ' 17:00:00';

if ($equipment_id === 0) {
    echo json_encode(["success" => false, "message" => "No equipment selected."]);
    exit();
}

// Check equipment status
$result = $conn->query("SELECT status FROM equipment WHERE equipment_id = $equipment_id");
if (!$result || $result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Equipment not found."]);
    exit();
}
$eq = $result->fetch_assoc();
if ($eq['status'] !== 'Available') {
    echo json_encode(["success" => false, "message" => "Equipment is {$eq['status']}, not Available."]);
    exit();
}

// Insert
$sql = sprintf(
    "INSERT INTO borrow_transactions 
    (student_id, equipment_id, borrower_name, student_number, subject, quantity, borrow_date, due_date, purpose, status)
    VALUES (%d, %d, '%s', '%s', '%s', %d, '%s', '%s', '%s', 'Pending')",
    $student_id,
    $equipment_id,
    $conn->real_escape_string($borrower_name),
    $conn->real_escape_string($student_number),
    $conn->real_escape_string($subject),
    $quantity,
    $borrow_date,
    $due_date,
    $conn->real_escape_string($purpose)
);

if ($conn->query($sql)) {
    echo json_encode([
        "success"        => true,
        "message"        => "Borrow request submitted successfully.",
        "transaction_id" => $conn->insert_id
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Insert error: " . $conn->error]);
}

$conn->close();
?>