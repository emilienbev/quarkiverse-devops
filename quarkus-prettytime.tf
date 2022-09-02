# Create repository
resource "github_repository" "quarkus_prettytime" {
  name                   = "quarkus-prettytime"
  description            = "Quarkus Extension for Social Style Date and Time Formatting"
  archive_on_destroy     = true
  delete_branch_on_merge = true
  has_issues             = true
  vulnerability_alerts   = true
  topics                 = ["quarkus-extension"]
  lifecycle {
    ignore_changes = [
      # Workaround for integrations/terraform-provider-github#1037.
      branches,
    ]
  }

  # Do not use the template below in new repositories. This is kept for backward compatibility with existing repositories
  template {
    owner      = "quarkiverse"
    repository = "quarkiverse-template"
  }
}

# Create team
resource "github_team" "quarkus_prettytime" {
  name                      = "quarkiverse-prettytime"
  description               = "Quarkiverse team for the Prettytime extension"
  create_default_maintainer = false
  privacy                   = "closed"
  parent_team_id            = data.github_team.quarkiverse_members.id
}

# Add team to repository
resource "github_team_repository" "quarkus_prettytime" {
  team_id    = github_team.quarkus_prettytime.id
  repository = github_repository.quarkus_prettytime.name
  permission = "maintain"
}

# Add users to the team
resource "github_team_membership" "quarkus_prettytime" {
  for_each = { for tm in ["gastaldi"] : tm => tm }
  team_id  = github_team.quarkus_prettytime.id
  username = each.value
  role     = "maintainer"
}

# Enable apps in repository
resource "github_app_installation_repository" "quarkus_prettytime" {
  for_each = { for app in [local.applications.lgtm] : app => app }
  # The installation id of the app (in the organization).
  installation_id = each.value
  repository      = github_repository.quarkus_prettytime.name
}

# Protect main branch
resource "github_branch_protection" "quarkus_prettytime" {
  repository_id = github_repository.quarkus_prettytime.id
  pattern       = "main"
  required_status_checks {
    contexts = ["build"]
  }
}