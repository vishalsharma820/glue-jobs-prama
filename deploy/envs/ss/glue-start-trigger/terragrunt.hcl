include {
  path = find_in_parent_folders("root.hcl")
}

# Dependency on the Glue Workflow
dependency "workflow" {
  config_path = "../glue-workflow"

  mock_outputs = {
    name = "demo-glue-workflow"
  }
}

# Dependency on Glue Job A
dependency "job_a" {
  config_path = "../glue-job-a"

  mock_outputs = {
    name = "job-a-transform"  # ✅ fixed: use "name" not "job_name"
  }
}

terraform {
  source = "../../../modules/glue-trigger"
}

inputs = {
  trigger_name        = "start-trigger"
  trigger_description = "Start scheduled trigger for job A"
  workflow_name       = dependency.workflow.outputs.name
  type                = "SCHEDULED"
  schedule            = "cron(0 14 * * ? *)"

  actions = [
    {
      job_name = dependency.job_a.outputs.name
    }
  ]

  start_on_creation   = true
  trigger_enabled     = true
}
