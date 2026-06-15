
resource "opentelekomcloud_fgs_dependency_version_v2" "test" {
  name    = format("%s-%s", var.tag_app_group, "postgres-dependency-8.20.0")
  runtime = "Node.js20.15"
  file    = filebase64("${path.module}/../dependency-postgres/postgres-dependency-8.20.0.zip")
  description = "Dependency package for PostgreSQL client v8.20.0 "
}

output "resource_id" {
  value = opentelekomcloud_fgs_dependency_version_v2.test.id  
}

output "dependency_id" {
  value = opentelekomcloud_fgs_dependency_version_v2.test.dependency_id
}

output "dependancy_package_version" {
  value = opentelekomcloud_fgs_dependency_version_v2.test.version
}

output "dependancy_download_link" {
  value = opentelekomcloud_fgs_dependency_version_v2.test.download_link
}

output "dependancy_correct_id" {
  value = trimsuffix(basename(opentelekomcloud_fgs_dependency_version_v2.test.download_link), ".zip")
}