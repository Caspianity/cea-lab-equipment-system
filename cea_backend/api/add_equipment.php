<?php
include '../config/db.php';

$data = json_decode(file_get_contents("php://input"), true);

$equipment_name = trim($data['equipment_name'] ?? '');
$category       = trim($data['category'] ?? '');
$location       = trim($data['location'] ?? '');

if (empty($equipment_name) || empty($category)) {
    http_response_code(400);
    echo json_encode(["success" => false, "message" => "Equipment name and category are required."]);
    exit();
}

// Auto-generate a unique QR code: prefix + 3-letter category + timestamp
$prefix   = strtoupper(substr(preg_replace('/\s+/', '', $category), 0, 3));
$qr_code  = $prefix . '-' . strtoupper(substr(md5(uniqid()), 0, 6));

// Make sure it's unique
$exists = true;
while ($exists) {
    $ck = $conn->prepare("SELECT equipment_id FROM equipment WHERE qr_code = ?");
    $ck->bind_param("s", $qr_code);
    $ck->execute();
    $ck->store_result();
    if ($ck->num_rows === 0) {
        $exists = false;
    } else {
        $qr_code = $prefix . '-' . strtoupper(substr(md5(uniqid()), 0, 6));
    }
    $ck->close();
}

$stmt = $conn->prepare("INSERT INTO equipment (equipment_name, category, qr_code, status, location) VALUES (?, ?, ?, 'Available', ?)");
$stmt->bind_param("ssss", $equipment_name, $category, $qr_code, $location);

if ($stmt->execute()) {
    echo json_encode([
        "success"      => true,
        "message"      => "Equipment added successfully.",
        "equipment_id" => $stmt->insert_id,
        "qr_code"      => $qr_code
    ]);
} else {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Failed to add equipment: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>