/*
  The APIs defined here are must be enabled in order to stand up this exercise.
*/

resource "google_project_service" "services" {
  for_each = toset([
    "container.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ])

  project = google_project.project.id
  service = each.value
}
