data "spotify_search_track" "ai_tracks" {
  for_each = var.track_queries

  artist = each.value.artist
  name   = each.value.name
  limit  = 1
}

locals {
  spotify_track_ids = compact([
    for track in data.spotify_search_track.ai_tracks : try(track.tracks[0].id, null)
  ])
}

resource "spotify_playlist" "ai_generated" {
  name        = var.playlist_name
  description = "AI-generated playlist from user preferences, managed with Terraform"
  public      = false

  tracks = local.spotify_track_ids
}