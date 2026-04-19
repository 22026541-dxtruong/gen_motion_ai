param(
  [string]$BaseUrl = "http://localhost:3000",
  [string]$Email = "",
  [string]$Password = "AuthE2E@12345",
  [string]$ResetToken = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
  param([string]$Message)
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Assert-True {
  param(
    [bool]$Condition,
    [string]$Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

function Invoke-Json {
  param(
    [Parameter(Mandatory = $true)][string]$Method,
    [Parameter(Mandatory = $true)][string]$Path,
    [object]$Body = $null,
    [string]$AccessToken = ""
  )

  $headers = @{}
  if ($AccessToken -ne "") {
    $headers["Authorization"] = "Bearer $AccessToken"
  }

  $requestParams = @{
    Method             = $Method
    Uri                = "$BaseUrl$Path"
    Headers            = $headers
    ContentType        = "application/json"
    SkipHttpErrorCheck = $true
  }

  if ($null -ne $Body) {
    $requestParams["Body"] = ($Body | ConvertTo-Json -Depth 10)
  }

  $response = Invoke-WebRequest @requestParams
  $content = $response.Content
  $json = $null

  if (-not [string]::IsNullOrWhiteSpace($content)) {
    try {
      $json = $content | ConvertFrom-Json
    } catch {
      $json = $null
    }
  }

  return [pscustomobject]@{
    StatusCode = [int]$response.StatusCode
    Json       = $json
    Raw        = $content
    Headers    = $response.Headers
  }
}

function Is-Success {
  param([int]$StatusCode)
  return $StatusCode -ge 200 -and $StatusCode -lt 300
}

if ([string]::IsNullOrWhiteSpace($Email)) {
  $seed = [Guid]::NewGuid().ToString("N").Substring(0, 8)
  $Email = "auth-e2e-$seed@example.com"
}

$isPlaceholderResetToken = $false
if (-not [string]::IsNullOrWhiteSpace($ResetToken)) {
  $trimmedResetToken = $ResetToken.Trim()
  if (
    $trimmedResetToken -eq "<token-from-email>" -or
    $trimmedResetToken -eq "token-from-email" -or
    ($trimmedResetToken.StartsWith("<") -and $trimmedResetToken.EndsWith(">"))
  ) {
    $isPlaceholderResetToken = $true
  }
}

$newPassword = "$Password-New1!"

Write-Host "Auth E2E verification started" -ForegroundColor Green
Write-Host "BaseUrl: $BaseUrl"
Write-Host "Email: $Email"

Write-Step "Health check: verify backend is reachable"
try {
  $null = Invoke-WebRequest -Method GET -Uri "$BaseUrl/api" -SkipHttpErrorCheck
} catch {
  throw "Cannot reach backend at $BaseUrl. Start neura-gen API first."
}

Write-Step "Register"
$registerRes = Invoke-Json -Method POST -Path "/auth/register" -Body @{
  email    = $Email
  password = $Password
}
Assert-True (Is-Success $registerRes.StatusCode) "Register failed: $($registerRes.Raw)"
Assert-True ($null -ne $registerRes.Json.accessToken) "Register missing accessToken"
Assert-True ($null -ne $registerRes.Json.refreshToken) "Register missing refreshToken"
$accessToken = [string]$registerRes.Json.accessToken
$refreshToken = [string]$registerRes.Json.refreshToken
Write-Host "PASS register"

Write-Step "Get current user profile (/users/me)"
$meRes = Invoke-Json -Method GET -Path "/users/me" -AccessToken $accessToken
Assert-True (Is-Success $meRes.StatusCode) "Get me failed: $($meRes.Raw)"
Assert-True ([string]$meRes.Json.email -eq $Email) "Get me email mismatch"
Write-Host "PASS /users/me"

Write-Step "Refresh token"
$refreshRes = Invoke-Json -Method POST -Path "/auth/refresh" -Body @{
  refreshToken = $refreshToken
}
Assert-True (Is-Success $refreshRes.StatusCode) "Refresh failed: $($refreshRes.Raw)"
Assert-True ($null -ne $refreshRes.Json.accessToken) "Refresh missing accessToken"
Assert-True ($null -ne $refreshRes.Json.refreshToken) "Refresh missing refreshToken"
$accessToken = [string]$refreshRes.Json.accessToken
$refreshToken = [string]$refreshRes.Json.refreshToken
Write-Host "PASS refresh"

Write-Step "Change password"
$changeRes = Invoke-Json -Method PATCH -Path "/auth/change-password" -AccessToken $accessToken -Body @{
  oldPassword = $Password
  newPassword = $newPassword
}
Assert-True (Is-Success $changeRes.StatusCode) "Change password failed: $($changeRes.Raw)"
Write-Host "PASS change-password"

Write-Step "Verify old password login should fail"
$oldLoginRes = Invoke-Json -Method POST -Path "/auth/login" -Body @{
  email    = $Email
  password = $Password
}
Assert-True ($oldLoginRes.StatusCode -eq 401) "Old password login should be 401, got $($oldLoginRes.StatusCode)"
Write-Host "PASS old password rejected"

Write-Step "Login with new password"
$newLoginRes = Invoke-Json -Method POST -Path "/auth/login" -Body @{
  email    = $Email
  password = $newPassword
}
Assert-True (Is-Success $newLoginRes.StatusCode) "Login with new password failed: $($newLoginRes.Raw)"
$accessToken = [string]$newLoginRes.Json.accessToken
$refreshToken = [string]$newLoginRes.Json.refreshToken
Write-Host "PASS new password login"

Write-Step "Forgot password"
$forgotRes = Invoke-Json -Method POST -Path "/auth/forgot-password" -Body @{
  email = $Email
}
Assert-True (Is-Success $forgotRes.StatusCode) "Forgot password failed: $($forgotRes.Raw)"
Assert-True ($null -ne $forgotRes.Json.message) "Forgot password missing message"
Write-Host "PASS forgot-password"

if (-not [string]::IsNullOrWhiteSpace($ResetToken) -and -not $isPlaceholderResetToken) {
  Write-Step "Reset password using provided token"
  $resetRes = Invoke-Json -Method POST -Path "/auth/reset-password" -Body @{
    token       = $ResetToken
    newPassword = $Password
  }
  Assert-True (Is-Success $resetRes.StatusCode) "Reset password failed: $($resetRes.Raw)"
  Write-Host "PASS reset-password"
} else {
  Write-Step "Reset password"
  if ($isPlaceholderResetToken) {
    Write-Host "SKIP reset-password (placeholder token detected)" -ForegroundColor Yellow
  } else {
    Write-Host "SKIP reset-password (provide -ResetToken '<real-token-from-email>')" -ForegroundColor Yellow
  }
}

Write-Step "Logout current session"
$logoutRes = Invoke-Json -Method POST -Path "/auth/logout" -AccessToken $accessToken -Body @{
  refreshToken = $refreshToken
}
Assert-True (Is-Success $logoutRes.StatusCode) "Logout failed: $($logoutRes.Raw)"
Write-Host "PASS logout"

Write-Step "Verify logged out refresh token is revoked"
$refreshAfterLogoutRes = Invoke-Json -Method POST -Path "/auth/refresh" -Body @{
  refreshToken = $refreshToken
}
Assert-True ($refreshAfterLogoutRes.StatusCode -eq 401) "Refresh after logout should be 401, got $($refreshAfterLogoutRes.StatusCode)"
Write-Host "PASS logout revocation"

Write-Step "Login again for logout-all test"
$loginAgainRes = Invoke-Json -Method POST -Path "/auth/login" -Body @{
  email    = $Email
  password = $newPassword
}
Assert-True (Is-Success $loginAgainRes.StatusCode) "Re-login failed: $($loginAgainRes.Raw)"
$accessToken = [string]$loginAgainRes.Json.accessToken
$refreshToken = [string]$loginAgainRes.Json.refreshToken

Write-Step "Logout all sessions"
$logoutAllRes = Invoke-Json -Method POST -Path "/auth/logout-all" -AccessToken $accessToken
Assert-True (Is-Success $logoutAllRes.StatusCode) "Logout-all failed: $($logoutAllRes.Raw)"
Write-Host "PASS logout-all"

Write-Step "Verify refresh token invalid after logout-all"
$refreshAfterLogoutAllRes = Invoke-Json -Method POST -Path "/auth/refresh" -Body @{
  refreshToken = $refreshToken
}
Assert-True ($refreshAfterLogoutAllRes.StatusCode -eq 401) "Refresh after logout-all should be 401, got $($refreshAfterLogoutAllRes.StatusCode)"
Write-Host "PASS logout-all revocation"

Write-Step "Google OAuth endpoint check"
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect = $false
$httpClient = [System.Net.Http.HttpClient]::new($handler)
try {
  $googleRes = $httpClient.GetAsync("$BaseUrl/auth/google").GetAwaiter().GetResult()
  $googleStatusCode = [int]$googleRes.StatusCode

  if ($googleStatusCode -ge 300 -and $googleStatusCode -lt 400) {
    $locationHeader = [string]$googleRes.Headers.Location
    Assert-True ($locationHeader -ne "") "Google endpoint redirect but missing Location header"
    Write-Host "PASS google endpoint redirect ($googleStatusCode): $locationHeader"
  } elseif ($googleStatusCode -eq 503) {
    Write-Host "WARN google endpoint not configured in BE env (503)." -ForegroundColor Yellow
  } else {
    throw "Unexpected google endpoint status: $googleStatusCode"
  }
} finally {
  $httpClient.Dispose()
  $handler.Dispose()
}

Write-Host ""
Write-Host "Auth E2E verification completed successfully." -ForegroundColor Green
