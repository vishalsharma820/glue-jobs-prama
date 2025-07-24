include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/glue-workflow"
}

inputs = {
  workflow_name        = "titanic-glue-workflow"                
  workflow_description = "Workflow to orchestrate Titianic data glue jobs" 
  max_concurrent_runs  = 1                                   
  default_run_properties = {}                                 
}
