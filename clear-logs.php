<?php

require_once __DIR__ . "/utils.php";

if (!isset($_GET["repo"])) {
    jsonResponse([
     "status" => "error",
     "message" => "Repository name query [repo] not provided"
    ], 400);
}

$repo = $_GET["repo"];
//$logFile = "/srv/apps/webhook/logs/" . $repo . "log";
$logFile = "/srv/apps/webhook/webhook.log";

$format = "sudo -u deployer truncate -s0 %s";
$cmd = sprintf($format, $logFile);
$retVal = exec($cmd);

jsonResponse([
    "status" => "success",
    "message" => "Logs for " . $repo . " cleared successfully",
    "return_value" => $retVal
], 200);
