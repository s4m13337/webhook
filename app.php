<?php
include("config.php");
session_start();

// If session does not exist, redirect to login
if (
    !isset($_SESSION["authenticated"], $_SESSION["id"]) ||
    !$_SESSION["authenticated"] ||
    $_SESSION["id"] !== ADMIN_SESSION_ID
) {
    header("Location: login.php");
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BikeFixUp Webhook Admin</title>
</head>

<body>
    <h1>BikeFixUp WebHook Admin</h1>
    <a href="logout.php">Log out</a>
</body>

</html>