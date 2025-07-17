include {
  path = find_in_parent_folders("root.hcl")
}

dependency "workflow" {
  config_path = "../glue-workflow"

  mock_outputs = {
    name = "demo-glue-workflow"
  }
}

dependency "job_a" {
  config_path = "../glue-job-a"

  mock_outputs = {
    job_name = "job-a-transform" # ✅ fix: must match actual output key name
  }
}

terraform {
  source = "../../../modules/glue-trigger"
}

inputs = {
  trigger_name        = "start-trigger"
  trigger_description = "Start scheduled trigger for job A"   # ✅ optional but helpful
  workflow_name       = dependency.workflow.outputs.name
  type                = "SCHEDULED"
  schedule            = "cron(0 14 * * ? *)"  # runs at 2 PM UTC daily

  actions = [
    {
      job_name = dependency.job_a.outputs.name  # ✅ fix: should be job_name not name
    }
  ]

  start_on_creation   = true
  trigger_enabled     = true
}
