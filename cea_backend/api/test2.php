<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header("Content-Type: application/json");

include '../config/db.php';

echo json_encode(["step" => "db connected"]);