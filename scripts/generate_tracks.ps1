function Read-Required($message) {
    do {
        $value = Read-Host $message
    } while ([string]::IsNullOrWhiteSpace($value))

    return $value
}

Write-Host ""
Write-Host "=== AI Spotify Playlist Generator ==="
Write-Host ""

$playlistName = Read-Required "Playlist name"
$mood = Read-Required "Mood / vibe example: night drive, gym, deep focus"
$genresInput = Read-Required "Genres separated by commas example: synthwave, electronic, indie rock"
$energy = Read-Required "Energy level example: low, medium, high, medium-high"
$avoidInput = Read-Required "What should the AI avoid? example: sad acoustic, slow piano"
$trackCountInput = Read-Required "Number of tracks"

while (-not ($trackCountInput -as [int]) -or [int]$trackCountInput -le 0) {
    $trackCountInput = Read-Required "Please enter a valid positive number of tracks"
}

$trackCount = [int]$trackCountInput

$genres = $genresInput.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
$avoid = $avoidInput.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

$userPreferences = @{
    playlist_name    = $playlistName
    mood             = $mood
    genres           = $genres
    energy           = $energy
    avoid            = $avoid
    number_of_tracks = $trackCount
}

$userPreferencesJson = $userPreferences | ConvertTo-Json -Depth 10

$prompt = @"
You are an AI music curator.

Generate a Spotify-style playlist based on these user preferences:

$userPreferencesJson

Return ONLY valid JSON.
No markdown.
No explanation.

Use exactly this JSON structure:

{
  "playlist_name": "$playlistName",
  "track_queries": {
    "track01": {
      "artist": "Artist Name",
      "name": "Track Name",
      "reason": "Short reason why it matches the user preferences"
    }
  }
}

Rules:
- Generate exactly $trackCount tracks.
- Use real artists and real song names.
- Avoid the disliked styles.
- Make the playlist coherent.
- Prefer songs likely to exist on Spotify.
- Do not include fake songs.
"@

$body = @{
    model  = "llama3.2"
    prompt = $prompt
    stream = $false
    format = "json"
} | ConvertTo-Json -Depth 20

Write-Host ""
Write-Host "Generating playlist with local AI..."
Write-Host ""

$response = Invoke-RestMethod `
    -Uri "http://localhost:11434/api/generate" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"

$generatedJson = $response.response | ConvertFrom-Json

$generatedJson | ConvertTo-Json -Depth 20 | Set-Content ".\terraform\generated.auto.tfvars.json"
Write-Host ""
Write-Host "Done. AI-generated Terraform variables saved to terraform/generated.auto.tfvars.json"
Write-Host ""