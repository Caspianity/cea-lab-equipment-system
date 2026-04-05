<?php
include '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

$transaction_id = intval($data['transaction_id'] ?? 0);
$action         = trim($data['action'] ?? ''); // 'approve' or 'reject'

if ($transaction_id === 0 || !in_array($action, ['approve', 'reject'])) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "transaction_id and action (approve/reject) required."]);
    exit();
}

// Get transaction
$check = $conn->prepare("SELECT equipment_id FROM borrow_transactions WHERE transaction_id = ?");
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

if ($action === 'approve') {
    // Update transaction status
    $stmt = $conn->prepare("UPDATE borrow_transactions SET status = 'Approved' WHERE transaction_id = ?");
    $stmt->bind_param("i", $transaction_id);
    $stmt->execute();
    $stmt->close();

    // Update equipment to Borrowed
    $stmt2 = $conn->prepare("UPDATE equipment SET status = 'Borrowed' WHERE equipment_id = ?");
    $stmt2->bind_param("i", $equipment_id);
    $stmt2->execute();
    $stmt2->close();

    echo json_encode(["success" => true, "message" => "Request approved."]);

} else {
    // Reject — just update status
    $stmt = $conn->prepare("UPDATE borrow_transactions SET status = 'Rejected' WHERE transaction_id = ?");
    $stmt->bind_param("i", $transaction_id);
    $stmt->execute();
    $stmt->close();

    echo json_encode(["success" => true, "message" => "Request rejected."]);
}

$conn->close();
?>