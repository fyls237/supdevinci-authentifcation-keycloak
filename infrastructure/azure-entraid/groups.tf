# Create group
resource "azuread_group" "education" {
  display_name     = "Education Department"
  security_enabled = true

}

resource "azuread_group_member" "education_members" {
  for_each = { for user in azuread_user.users : user.mail_nickname => user if user.department == "Education" }

  group_object_id = azuread_group.education.id
  member_object_id = each.value.id
}

resource "azuread_group" "managers" {
  display_name = "Education - Managers"
  security_enabled = true
}

resource "azuread_group_member" "managers_members" {
  for_each = { for user in azuread_user.users : user.mail_nickname => user if user.job_title == "Manager" && user.department == "Education" }

  group_object_id = azuread_group.managers.id
  member_object_id = each.value.id
}

resource "azuread_group" "engineers" {
  display_name = "Education - Engineers"
  security_enabled = true
  
}

resource "azuread_group_member" "engineers_members" {
  for_each = { for user in azuread_user.users : user.mail_nickname => user if user.job_title == "Engineer" && user.department == "Education" }

  group_object_id = azuread_group.engineers.id
  member_object_id = each.value.id
}
