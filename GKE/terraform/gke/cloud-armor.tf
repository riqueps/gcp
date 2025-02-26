module security_policy {
  source = "GoogleCloudPlatform/cloud-armor/google"

  project_id                           = var.gcp_project_id
  name                                 = "${var.env_name}-ca-policy"
  description                          = "Cloud Armor security policy with preconfigured rules, security rules and custom rules"
  default_rule_action                  = "deny(403)"
  type                                 = "CLOUD_ARMOR"
  layer_7_ddos_defense_enable          = true
  layer_7_ddos_defense_rule_visibility = "STANDARD"
  json_parsing                         = "STANDARD"
  log_level                            = "VERBOSE"

  pre_configured_rules                 = {}
  security_rules                       = {}
  custom_rules                         = {}
  threat_intelligence_rules            = {}
}