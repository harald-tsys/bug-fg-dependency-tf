##########################################################
# Create nodejs event function
##########################################################
resource "opentelekomcloud_fgs_function_v2" "MyFunction" {

  name   = format("%s-%s", var.tag_app_group, "myfunction")
  app    = "default"
  
  handler =  "src/index.handler"

  runtime   = "Node.js20.15"

  code_type = "zip"
  func_code     = filebase64(format("${path.module}/../function/%s", "function.zip"))
  code_filename = "function.zip"

  memory_size      = 512
  timeout          = 30
  max_instance_num = 1

  # set some environment variables
  user_data = jsonencode({
    "RUNTIME_LOG_LEVEL" : "DEBUG",
  })

  tags = {
    "app_group" = var.tag_app_group
  }

  depend_list = [
    # should:
    # opentelekomcloud_fgs_dependency_version_v2.test.dependency_id

    # not working:
    # opentelekomcloud_fgs_dependency_version_v2.test.id

    # working
    trimsuffix(basename(opentelekomcloud_fgs_dependency_version_v2.test.download_link), ".zip")
  ]

}

output "MY_FUNCTION_URN" {
  value = opentelekomcloud_fgs_function_v2.MyFunction.urn
}

output "MY_FUNCTION_VERSION" {
  value = opentelekomcloud_fgs_function_v2.MyFunction.version
}