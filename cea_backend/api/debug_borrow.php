<?php
include '../config/db.php';

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

// Convert dates same way borrow_equipment.php does
$due_date_raw = trim($data['due_date'] ?? '');
$due_date_converted = date('Y-m-d H:i:s', strtotime($due_date_raw));

echo json_encode([
    "raw_input"       => $raw,
    "parsed_data"     => $data,
    "due_date_raw"    => $due_date_raw,
    "due_date_converted" => $due_date_converted,
    "equipment_id"    => intval($data['equipment_id'] ?? 0),
    "json_error"      => json_last_error_msg(),
]);
?>