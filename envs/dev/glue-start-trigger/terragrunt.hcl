include {
  path = find_in_parent_folders("root.hcl")
}

# Dependency on the Glue Workflow
dependency "workflow" {
  config_path = "../glue-workflow"

  mock_outputs = {
    name = "demo-glue-workflow" # Must match the output key from glue-workflow module
  }
}

# Dependency on Glue Job A
dependency "job_a" {
  config_path = "../glue-job-a"

  mock_outputs = {
    job_name = "job-a-transform" # Must match the output key from glue-job-a module
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
  schedule            = "cron(0 14 * * ? *)"  # 2 PM UTC daily

  actions = [
    {
      job_name = dependency.job_a.outputs.name  # ✅ fixed: referencing correct output key
    }
  ]

  start_on_creation   = true
  trigger_enabled     = true
}
