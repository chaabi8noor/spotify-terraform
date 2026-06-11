output "playlist_name" {
  value = var.playlist_name
}

output "ai_generated_tracks" {
  value = [
    for key, track in var.track_queries : {
      number = key
      artist = track.artist
      name   = track.name
      reason = track.reason
    }
  ]
}

output "spotify_track_ids" {
  value = local.spotify_track_ids
}

output "spotify_playlist_url" {
  value = "https://open.spotify.com/playlist/${spotify_playlist.ai_generated.id}"
}