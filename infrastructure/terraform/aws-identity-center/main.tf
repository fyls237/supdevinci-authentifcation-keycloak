resource "aws_identitystore_user" "user" {
  for_each = { for user in local.groups_flatten : user.email => user }

  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]

  user_name    = each.value.email
  display_name = "${each.value.first_name} ${each.value.last_name}"
  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }
  emails {
    value = each.value.email
    type  = "work"
  }
}

resource "aws_identitystore_group" "groups" {
  for_each = { for idx, group in local.groups_list : group.group_name => group }

  display_name      = each.value.name
  description       = each.value.description
  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "group_memberships" {
  for_each = {
    for group in local.groups_flatten :
    "${group.group_name}-${group.email}" => group
  }

  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]
  group_id          = aws_identitystore_group.groups[each.value.group_name].group_id
  member_id         = aws_identitystore_user.user[each.value.email].user_id
}