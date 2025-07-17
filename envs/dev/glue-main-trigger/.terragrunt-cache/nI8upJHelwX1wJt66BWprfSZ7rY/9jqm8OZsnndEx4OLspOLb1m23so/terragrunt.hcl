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
    name = "job-a-transform"
  }
}

dependency "job_b" {
  config_path = "../glue-job-b"
  mock_outputs = {
    name = "job-b-postprocess"
  }
}

terraform {
  source = "../../../modules/glue-trigger"
}

inputs = {
  trigger_name        = "trigger-a-to-b"
  workflow_name       = dependency.workflow.outputs.name
  type                = "CONDITIONAL"
  start_on_creation   = true
  trigger_enabled     = true

  predicate = {
    logical = "ANY"
    conditions = [
      {
        job_name = dependency.job_a.outputs.name
        state    = "SUCCEEDED"
      }
    ]
  }

  actions = [
    {
      job_name = dependency.job_b.outputs.name
    }
  ]
}
