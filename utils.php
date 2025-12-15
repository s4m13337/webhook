<?php

function jsonResponse(mixed $data, int $statusCode)
{
    http_response_code($statusCode);
    header("Content-Type: application/json; charset=utf-8");
    echo json_encode($data);
    exit();
}
