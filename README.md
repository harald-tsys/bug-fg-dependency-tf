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


## Issue 1 - depend_list - [GitHub Issue 3423](https://github.com/opentelekomcloud/terraform-provider-opentelekomcloud/issues/3423)

After setting environment variables, execute:

```
make tf_apply
```

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


`opentelekomcloud_fgs_dependency_version_v2.test.id` should be `id`.
returned by of
POST https://functiongraph.eu-de.otc.t-systems.com/v2/${OTC_SDK_PROJECTID}/fgs/dependencies/version

## Issue 2 - not possible to remove dependency

It`s not possible to remove dependency from function after it has been applied once.

## Issue 3 - error if code has not been changed

On second tf_apply or on changes on depend_list, following error
occurs. 


```
 Error: error updating code of function: Bad request with: [PUT https://functiongraph.eu-de.otc.t-systems.com/v2/d52e41d2434941b194ce3f91b1b12f8a/fgs/functions/urn:fss:eu-de:d52e41d2434941b194ce3f91b1b12f8a:function:default:fg-tf-bug-myfunction/code], error message: {
│  "error_code": "FSS.1011",
│  "error_msg": "zip: not a valid zip file",
│  "details": {
│   "error_msg": "Invalid function code."
│  }
│ }
```

This error always occurs, if there is no change to function code.

On changes to other settings this message should be ignored.
