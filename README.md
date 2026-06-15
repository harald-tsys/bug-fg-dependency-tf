# bug-fg-dependency-tf

Sample code for https://github.com/opentelekomcloud/terraform-provider-opentelekomcloud/issues/3403


Following environment variables must be set:

| Environment variable | description                                     |
| -------------------- | ----------------------------------------------- |
| OTC_SDK_AK           | Access key                                      |
| OTC_SDK_SK           | Secret key                                      |
| OTC_SDK_DOMAIN_NAME  | Domain name eg. OTC-EU-DE-000000000010000XXXXX" | 
| OTC_SDK_PROJECTNAME  | Project name e.g. eu_de                         |
| OTC_IAM_ENDPOINT     | https://iam.eu-de.otc.t-systems.com/v3          |
| OTC_USER_NAME        | User name                                       |
| OTC_USER_PASSWORD    | User password                                   |
| OTC_SDK_PROJECTID    | Project ID                                      |


```json
"dependencies": [
  {
   "id": "b4c63de9-142f-47ee-a0df-744fa05dde6c",
   "owner": "d52e41d2434941b194ce3f91b1b12f8a",
   "link": "https://functionstorage-eu-de.obs.eu-de.otc.t-systems.com/depends/d52e41d2434941b194ce3f91b1b12f8a/9926fdbc-b9fd-47cb-9097-517663e0b772.zip",
   "runtime": "Node.js20.15",
   "etag": "c35736d0b86e857113784c454a5ca4d8",
   "size": 160120,
   "name": "fg-tf-bug-postgres-dependency-8.20.0",
   "description": "Dependency package for PostgreSQL client v8.20.0 ",
   "file_name": "fg-tf-bug-postgres-dependency-8.20.0.zip",
   "version": 1,
   "is_shared": false,
   "last_modified": "2026-06-15T12:48:27+02:00"
  }
]
  ```

## Issue 1

`depend_list` is defined in [opentelekomcloud_fgs_function_v2](https://registry.terraform.io/providers/opentelekomcloud/opentelekomcloud/latest/docs/resources/fgs_function_v2#depend_list-4) as 


> 
> - depend_list - (Optional, List) Specifies the ID list of the dependencies.
> 

But to get it work, following has to be used:

```
depend_list = [
    # should:
    # opentelekomcloud_fgs_dependency_version_v2.test.dependency_id

    # not working:
    # opentelekomcloud_fgs_dependency_version_v2.test.id

    # working
    trimsuffix(basename(opentelekomcloud_fgs_dependency_version_v2.test.download_link), ".zip")
  ] 
```

Question: 
`dependency_id` and `resource_id` returned by 
`opentelekomcloud_fgs_dependency_version_v2` are both the same value.
Shouldn't `dependency_id` be same as basename of zip?

## Issue 2

It`s not possible to remove dependency from function after it has been applied once.

## Issue 3

On second tf_apply or on changes on depend_list, following error
occurs. (This error occurs, if function code has not been changed)

```
 Error: error updating code of function: Bad request with: [PUT https://functiongraph.eu-de.otc.t-systems.com/v2/d52e41d2434941b194ce3f91b1b12f8a/fgs/functions/urn:fss:eu-de:d52e41d2434941b194ce3f91b1b12f8a:function:default:fg-tf-bug-myfunction/code], error message: {
│  "error_code": "FSS.1011",
│  "error_msg": "zip: not a valid zip file",
│  "details": {
│   "error_msg": "Invalid function code."
│  }
│ }
```