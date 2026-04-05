<?php
include '../config/db.php';

$status = trim($_GET['status'] ?? ''); // Pending, Approved, Returned, All

$sql = "
    SELECT bt.*, e.equipment_name, e.category, e.qr_code
    FROM borrow_transactions bt
    JOIN equipment e ON bt.equipment_id = e.equipment_id
";

if (!empty($status) && $status !== 'All') {
    $sql .= " WHERE bt.status = ?";
    $sql .= " ORDER BY bt.borrow_date DESC";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $status);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    $sql .= " ORDER BY bt.borrow_date DESC";
    $result = $conn->query($sql);
}

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);

$conn->close();
?>