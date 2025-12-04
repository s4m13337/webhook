<?php
include("config.php");
session_start();

// If session exists, redirect to app
if (
    isset($_SESSION["authenticated"], $_SESSION["id"]) &&
    $_SESSION["authenticated"] &&
    $_SESSION["id"] === ADMIN_SESSION_ID
) {
    header("Location: app.php");
    exit();
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $username = $_POST["username"];
    $password = $_POST["password"];

    if ($username === ADMIN_USER && $password === ADMIN_PASSWORD) {
        $_SESSION["authenticated"] = true;
        $_SESSION["id"] = ADMIN_SESSION_ID;
        header("Location: app.php");
        exit();
    }
}

?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BikeFixUp Webhook</title>
    <style>
        body {
            background-color: black;
            color: whitesmoke;
        }
    </style>
</head>

<body>
    <h1>BikeFixUp Webhook Login</h1>
    <form action="login.php" method="post">
        <input type="text" name="username" placeholder="Username"> <br> <br>
        <input type="password" name="password" placeholder="Password"> <br> <br>
        <input type="submit" value="Login">
    </form>
</body>

</html>