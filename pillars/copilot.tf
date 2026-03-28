# GitHub Well-Architected Framework - Copilot Governance Pillar
#
# Addresses WAF guidance on managing GitHub Copilot at enterprise scale:
#   - Productivity: Track Copilot adoption, usage KPIs, and ROI.
#   - Governance: Control seat assignments, enforce acceptable-use policies,
#     and maintain cost accountability.
#   - Application Security: Ensure Copilot is used within secure, policy-compliant
#     workflows and that AI-generated code passes the same security gates as
#     human-authored code.
#
# References:
#   - https://wellarchitected.github.com/library/productivity/checklist/
#   - https://wellarchitected.github.com/library/governance/checklist/
#   - https://wellarchitected.github.com/library/application-security/checklist/

module "copilot_governance" {
  source = "../modules/copilot"

  governance_repository_name  = "copilot-governance"
  visibility                  = "internal"
  copilot_usage_workflow_path = abspath("${path.module}/../templates/workflows/copilot_usage_report.yml")
  copilot_team_id             = var.copilot_team_id

  copilot_labels = {
    "copilot:adoption"   = "0E8A16"
    "copilot:governance" = "1D76DB"
    "copilot:cost"       = "FEF2C0"
    "copilot:security"   = "B60205"
  }
}
