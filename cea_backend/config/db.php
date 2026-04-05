<?php
error_reporting(0);
ini_set('display_errors', 0);

$host     = "localhost";
$user     = "root";
$password = "";
$database = "cea_lab_system";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    // Headers already set by the calling file
    echo json_encode(["success" => false, "message" => "DB connection failed: " . $conn->connect_error]);
    exit();
}

$conn->set_charset("utf8");
?>