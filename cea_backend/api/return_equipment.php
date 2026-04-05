<?php
include '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

$transaction_id     = intval($data['transaction_id'] ?? 0);
$condition_returned = trim($data['condition_returned'] ?? 'Good');

if ($transaction_id === 0) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Transaction ID is required."]);
    exit();
}

// Get transaction to find equipment_id
$check = $conn->prepare("SELECT equipment_id, status FROM borrow_transactions WHERE transaction_id = ?");
$check->bind_param("i", $transaction_id);
$check->execute();
$res = $check->get_result();

if ($res->num_rows === 0) {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "Transaction not found."]);
    exit();
}

$tx = $res->fetch_assoc();
$equipment_id = $tx['equipment_id'];
$check->close();

// Update transaction
$return_date = date('Y-m-d H:i:s');
$stmt = $conn->prepare("UPDATE borrow_transactions SET status = 'Returned', return_date = ?, condition_returned = ? WHERE transaction_id = ?");
$stmt->bind_param("ssi", $return_date, $condition_returned, $transaction_id);
$stmt->execute();
$stmt->close();

// Update equipment status back to Available
$stmt2 = $conn->prepare("UPDATE equipment SET status = 'Available' WHERE equipment_id = ?");
$stmt2->bind_param("i", $equipment_id);
$stmt2->execute();
$stmt2->close();

echo json_encode(["success" => true, "message" => "Equipment returned successfully."]);

$conn->close();
?>