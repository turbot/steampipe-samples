resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  # NOTE: If Github changes/renews the GitHub Actions SSL certificates then the thumbprint may change. 
  # More details at, https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html

  tags = {
    "owner" : "johndoe@example.com",
    "purpose" : "steampipe_gh_oidc_demo"
  }
}

data "aws_iam_policy_document" "openid_trustrelationship" {
  statement {
    sid     = "OIDCTrust"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com",
      ]
    }
  }

  statement {
    sid     = "OIDCTrustCondition"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}",
        # Syntax:	repo:<orgName/repoName>:ref:refs/heads/branchName
        # Example:	repo:octo-org/octo-repo:ref:refs/heads/demo-branch
      ]
    }
  }
}

resource "aws_iam_role" "openid_role" {
  name                 = var.aws_iam_role_name
  path                 = "/steampipe/"
  assume_role_policy   = data.aws_iam_policy_document.openid_trustrelationship.json
  max_session_duration = 3600
  managed_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]

  tags = {
    "owner" : "johndoe@example.com",
    "purpose" : "steampipe_gh_oidc_demo"
  }
}
