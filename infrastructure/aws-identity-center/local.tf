locals {
  groups_yaml = file("${path.module}/groups.yaml")
  groups_data = yamldecode(local.groups_yaml)
  groups_list = local.groups_data.groups

  groups_flatten = flatten([
    for group in local.groups_list : [
      for user in group.users : {
        group_name = group.group_name
        first_name = user.first_name
        last_name  = user.last_name
        email      = user.email
        department = user.department
        job_title  = user.job_title
      }
    ]
  ])

  users_yaml = file("${path.module}/users.yaml")
  users_data = yamldecode(local.users_yaml)
  users_list = local.users_data.users
}