<?php

/**
 * BikeFixUp Webhook server
 * This server listens for requests from github which come whenever an event occurs
 * Based on the event and the repository, build scripts are run accordingly
 */

/**
 * Helper functions
 */
// Function to return JSON response
function jsonResponse(mixed $data, int $statusCode)
{
    http_response_code($statusCode);
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode($data);
    exit();
}

// Function to write logs to file
function writeLog(
    string $logString,
    string $logFilePath = __DIR__ . "/webhook.log",
) {
    $timestamp = date("Y-m-d H:i:s");
    file_put_contents(
        $logFilePath,
        $timestamp . " --- " . $logString . PHP_EOL,
        FILE_APPEND,
    );
}

// If a GET request is encountered, it means a browser is accessing
// In this case redirect to the App interface
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    header("Location: app.php");
    exit();
}

// Get headers
$headers = getallheaders();

// Get the raw POST body
$payload = file_get_contents("php://input");
$data = json_decode($payload, true); // true argument returns data as associative array

/**
 * The header contains the X-Hub-Signature-256 which can be used to verify if the request comes from github
 * If the signature verification fails, then the request can be rejected
 * The signature is computed by computing the SHA256 hash using HMAC using a key stored on the server
 * This key is used when creating the webhook
 */

// If signature is not present, return error and exit
$githubSignature = $headers["X-Hub-Signature-256"] ?? null;
if ($githubSignature === null) {
    jsonResponse(
        [
            "status" => "error",
            "message" => "Unauthorized: Signature missing!",
        ],
        401,
    );
}

// Proceed further to signature verifcation if signature header is present
$key = trim(file_get_contents("/srv/admin/vault/webhook.key")); // Trim removes new lines or carriage returns
$computedSignature = "sha256=" . hash_hmac("sha256", $payload, $key);

// If hash does not match, return error and exit
if (!hash_equals($githubSignature, $computedSignature)) {
    // hash_equals compares string in constant time to prevent timing attacks
    jsonResponse(
        [
            "status" => "error",
            "message" => "Forbidden: Signature verification failed!",
        ],
        403,
    );
}

/**
 * At this point the signature is verified and authenticity of the request is established.
 * Todo: Add rules to allow requests only from Github IPs for stronger security.
 *
 * The next steps include identifying the repository on which push event occurs and calling the respective deployment scripts.
 */

//writeLog(json_encode($data, JSON_PRETTY_PRINT));

// Get the repository name & branch name
$repositoryName = $data["repository"]["name"];
writeLog("The branch is " . $data["ref"]);
$branch = str_replace("refs/heads/", "", $data["ref"]);

// If branch is not main, respond with no content and terminate
// Bypass this for bf_backend temporarily
if ($branch !== "main" && $repositoryName !== "bf_backend") {
    writeLog(
        "Push event occured on " .
            $repositoryName .
            "/" .
            $branch .
            "; No further action will be done",
    );
    http_response_code(204);
    exit();
}

// Execute script based on repository name
writeLog(
    "Push event occured on repository: " .
        $repositoryName .
        " in branch: " .
        $branch,
);
switch ($repositoryName) {
    case "webhook-test":
        exec("nohup /srv/apps/deploy-scripts/webhook-test.deploy.sh &");
        break;

    case "xtraspare_frontend":
        writeLog("Starting deployment script for xtraspare_frontend");
        exec(
            "nohup sudo -u deployer /srv/apps/deploy-scripts/xtraspare_frontend.deploy.sh &",
        );
        break;

    case "xtraspare_backend":
        writeLog("Starting deployment script for xtraspare_backend");
        exec(
            "nohup sudo -u deployer /srv/apps/deploy-scripts/xtraspare_backend.deploy.sh &",
        );
        break;

    case "bf_backend":
        writeLog("Starting deployment script for bf_backend");

        #exec("nohup sudo -u deployer /srv/apps/deploy-scripts/bf_backend.deploy.sh &");
        exec("nohup sudo -u deployer /srv/apps/deploy-scripts/git-sync.sh  bf_backend &");
        break;

    case "partner-app-backend":
        writeLog("Starting deployment script for partner-app-backend");
        exec(
            "nohup sudo -u deployer /srv/apps/deploy-scripts/partner-app-backend.deploy.sh &",
        );
        break;

    case "crm":
        writeLog("Starting deployment script for CRM_new_backend");
        exec(
            "nohup sudo -u deployer /srv/apps/deploy-scripts/git-sync.sh crm &",
        );
        break;

    default:
        writeLog("No deployment script is available for " . $repositoryName);
        break;
}

// Response
http_response_code(202); // 202 tells Github that the request was accepted and the process has been queued.
