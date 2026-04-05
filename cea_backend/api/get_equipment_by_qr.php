<?php
include '../config/db.php';

$qr_code = trim($_GET['qr_code'] ?? '');

if (empty($qr_code)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "QR code is required."]);
    exit();
}

$stmt = $conn->prepare("SELECT * FROM equipment WHERE qr_code = ?");
$stmt->bind_param("s", $qr_code);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    http_response_code(404);
    echo json_encode(["success" => false, "message" => "Equipment not found."]);
    exit();
}

$equipment = $result->fetch_assoc();
echo json_encode(["success" => true, "data" => $equipment]);

$stmt->close();
$conn->close();
?>