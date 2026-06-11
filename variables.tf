variable "spotify_api_key" {
  type        = string
  description = "Spotify API key from the Spotify auth proxy"
  sensitive   = true
}

variable "playlist_name" {
  type    = string
  default = "AI Generated Playlist"
}

variable "track_queries" {
  type = map(object({
    artist = string
    name   = string
    reason = string
  }))

  default = {}
}