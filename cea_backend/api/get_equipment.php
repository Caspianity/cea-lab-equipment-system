<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include '../config/db.php';

$search   = trim($_GET['search'] ?? '');
$category = trim($_GET['category'] ?? '');

$sql    = "SELECT * FROM equipment WHERE 1=1";
$params = [];
$types  = "";

if (!empty($search)) {
    $sql     .= " AND equipment_name LIKE ?";
    $params[] = "%" . $search . "%";
    $types   .= "s";
}

if (!empty($category)) {
    $sql     .= " AND category = ?";
    $params[] = $category;
    $types   .= "s";
}

$sql .= " ORDER BY equipment_name ASC";

if (!empty($params)) {
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    $result = $conn->query($sql);
}

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data, "count" => count($data)]);
$conn->close();
?>