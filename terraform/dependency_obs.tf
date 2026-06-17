###################################################################################
# Code bucket to store dependency file
###################################################################################
resource "opentelekomcloud_obs_bucket" "codebucket" {
  bucket = format("%s-%s-%s", var.prefix, "dependencybucket", var.tag_app_group)
  acl    = "private"

  tags = {
    "app_group" = var.tag_app_group
  }
}

###################################################################################
# Code bucket object to upload dependency file
###################################################################################
resource "opentelekomcloud_obs_bucket_object" "code_object" {
  bucket       = opentelekomcloud_obs_bucket.codebucket.bucket
  key          = format("%s/%s", "code", basename(var.zip_file_name))
  source       = var.zip_file_name
  etag         = filemd5(var.zip_file_name)
  content_type = "application/zip"
}

resource "opentelekomcloud_fgs_dependency_version_v2" "dep_obs" {
  name    = format("%s-%s-obs", var.tag_app_group, "postgres-dependency-8.20.0")
  runtime = "Node.js20.15"
  link    = format("https://%s/%s/%s",
    opentelekomcloud_obs_bucket.codebucket.bucket_domain_name,
    "code",
    basename(var.zip_file_name)
  )
  description = "Dependency package for PostgreSQL client v8.20.0 "
}

output "obs_dependency_resource_id" {
  value = opentelekomcloud_fgs_dependency_version_v2.dep_obs.id  
}

output "obs_dependency_id" {
  value = opentelekomcloud_fgs_dependency_version_v2.dep_obs.dependency_id
}

output "obs_dependency_package_version" {
  value = opentelekomcloud_fgs_dependency_version_v2.dep_obs.version
}

output "obs_dependency_download_link" {
  value = opentelekomcloud_fgs_dependency_version_v2.dep_obs.download_link
}

output "obs_dependency_correct_id" {
  value = trimsuffix(basename(opentelekomcloud_fgs_dependency_version_v2.dep_obs.download_link), ".zip")
}