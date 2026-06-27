<?php
/**
 * Supabase HTTP Proxy for SIM800L
 * 
 * Upload this file to any standard web hosting (e.g., Hostinger, GoDaddy, cPanel) 
 * that supports plain HTTP access. 
 * 
 * Your SIM800L will send data via HTTP to:
 * http://your-website.com/supabase_http_proxy.php
 */

// Your Supabase Configuration
$SUPABASE_URL = "https://cxzzmfqxyxondlzledjn.supabase.co/rest/v1/odour_management_live?sensor_id=eq.SENS-001";
$SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4enptZnF4eXhvbmRsemxlZGpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NDExNDMsImV4cCI6MjA5ODExNzE0M30.JcSfMGc6u6PmlSNEzZA96r9IoWdV88C7z-n68RiouMk";

// Read the raw JSON payload coming from the SIM800L
$jsonPayload = file_get_contents('php://input');

// Initialize cURL to forward the request to Supabase over secure HTTPS
$ch = curl_init($SUPABASE_URL);

// Set up the required headers for Supabase
$headers = array(
    "apikey: " . $SUPABASE_KEY,
    "Authorization: Bearer " . $SUPABASE_KEY,
    "Content-Type: application/json",
    "Prefer: return=representation",
    "X-HTTP-Method-Override: PATCH"
);

curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PATCH");
curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonPayload);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);

// Execute and get the response from Supabase
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

// Echo the response back to the SIM800L (so the Arduino can read "pending_action")
http_response_code($httpCode);
echo $response;
?>
