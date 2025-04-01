# GitHub Well-Architected Framework Implementation

[![Terraform Tests](https://github.com/jgarverick/gh-tf-waf/actions/workflows/terraform_tests.yml/badge.svg)](https://github.com/jgarverick/gh-tf-waf/actions/workflows/terraform_tests.yml)

This repository provides a Terraform-based implementation of the [GitHub Well-Architected Framework](https://wellarchitected.github.com/). It helps you establish and maintain a secure, reliable, and efficient GitHub environment by codifying best practices across key pillars.

**This is a work in progress and is not yet complete. Expect things to not work right away as I make changes. If you see a need for a specific feature or fix, please open an issue.**

## Pillars

This implementation covers the following pillars:

-   **[Architecture](pillars/architecture.tf)**: Defines the structure and components of your GitHub environment, promoting modularity and scalability.
-   **[Application Security](pillars/appsec.tf)**: Implements security best practices to protect your code and data.
-   **[Collaboration](pillars/collaboration.tf)**: Enhances team collaboration through standardized templates, labels, and workflows.
-   **[Governance](pillars/governance.tf)**: Establishes policies and controls to manage your GitHub organization effectively.
-   **[Productivity](pillars/productivity.tf)**: Automates tasks and streamlines workflows to improve team productivity.

## Modules

The repository is organized into reusable Terraform modules:

-   **[action/](modules/action/)**: For creating and managing GitHub Actions secrets.
-   **[auth/](modules/auth/)**: For configuring authentication-related resources (SAML, OIDC).
-   **[enterprise/](modules/enterprise/)**: For managing enterprise-level settings.
-   **[org/](modules/org/)**: For organization-level settings.
-   **[project_boards/](modules/project_boards/)**: For creating and configuring project boards with WAF-aligned fields.
-   **[project_view/](modules/project_view/)**: For customizing project views and automating project management.
-   **[repo/](modules/repo/)**: For managing GitHub repositories, including security features and CODEOWNERS.
-   **[ruleset/](modules/ruleset/)**: For defining and enforcing rulesets for branch protection.
-   **[team/](modules/team/)**: For managing teams and permissions, following the principle of least privilege.

## Templates

The `templates/` directory contains templates for issues, pull requests, and other collaborative elements:

-   **[bug_report.md](templates/bug_report.md)**: Template for bug reports.
-   **[feature_request.md](templates/feature_request.md)**: Template for feature requests.
-   **[meeting_template.md](templates/meeting_template.md)**: Template for team meeting notes.
-   **[monorepo_change.md](templates/monorepo_change.md)**: Template for cross-component changes in monorepos.
-   **[pull_request_template.md](templates/pull_request_template.md)**: Template for pull requests.
-   **[release_template.md](templates/release_template.md)**: Template for release notes.
-   **[discussion_categories.yml](templates/discussion_categories.yml)**: Configuration for discussion categories.
-   **[workflows/](templates/workflows/)**: GitHub Actions workflows for automation:
    -   **[issue_automation.yml](templates/workflows/issue_automation.yml)**: Automates issue triage and labeling.
    -   **[project_automation.yml](templates/workflows/project_automation.yml)**: Automates project board updates.
    -   **[stale_issues.yml](templates/workflows/stale_issues.yml)**: Closes stale issues and pull requests.
    -   **[cross_repo_visibility.yml](templates/workflows/cross_repo_visibility.yml)**: Provides cross-repository visibility for monorepos.
    -   **[ci-cd.yml](templates/workflows/ci-cd.yml)**: Implements a CI/CD pipeline.

## Getting Started

1.  **Prerequisites:**
    -   [Terraform](https://www.terraform.io/downloads.html) installed
    -   [GitHub CLI](https://cli.github.com/) installed (for project view automation)
    -   GitHub personal access token with `repo`, `admin:org`, and `admin:enterprise` scopes

2.  **Configuration:**
    -   Clone the repository: `git clone <repository_url>`
    -   Configure the `providers.tf` file with your GitHub token and organization name.
    -   Customize the variables in `variables.tf` and `pillars/variables.tf` to match your organization's requirements.  Pay special attention to:
        -   `billing_email`:  The email address for billing notifications.
        -   `organization_name`: Your GitHub organization name.
        -   `admin_team_id`:  The ID of your administrators team (for ruleset bypass).
        -   `cross_functional_collaborators`:  Define cross-functional access.
    -   For project view automation, ensure the `gh` CLI is authenticated and has access to your organization.

3.  **Deployment:**
    -   Navigate to the `pillars/` directory: `cd pillars/`
    -   Run `terraform init` to initialize the Terraform environment.
    -   Run `terraform plan` to review the changes.
    -   Run `terraform apply` to apply the configuration.

## Contributing

Contributions are welcome! Please follow these guidelines:

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Adhere to the coding style and best practices used in the project.
4.  Write clear and concise commit messages.
5.  Test your changes thoroughly.
6.  Submit a pull request with a clear description of your changes.

## Pre-Commit Hooks

This repository uses [pre-commit](https://pre-commit.com/) to enforce code quality and style.  Install pre-commit and run it on your changes:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```
## License
This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute it as per the terms of the license.

## Additional Resources
-   [GitHub Well-Architected Framework](https://wellarchitected.github.com/)
-   [Terraform Documentation](https://www.terraform.io/docs/index.html)
-   [GitHub CLI Documentation](https://cli.github.com/manual/)
-   [GitHub Actions Documentation](https://docs.github.com/en/actions)
-   [GitHub API Documentation](https://docs.github.com/en/rest)
-   [GitHub Security Best Practices](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-security-advisories)
-   [GitHub Branch Protection Rules](https://docs.github.com/en/github/administering-a-repository/about-protected-branches)
-   [GitHub Repository Management](https://docs.github.com/en/github/administering-a-repository/about-repositories)
