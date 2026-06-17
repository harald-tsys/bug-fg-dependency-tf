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

To reproduce:

1. Set environment variables as described above
2. Apply changes

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


3. clean up
```
make tf_destroy
```




## Issue 2 - not possible to remove dependency [GitHub Issue 3425](https://github.com/opentelekomcloud/terraform-provider-opentelekomcloud/issues/3425)

It`s not possible to remove dependency from function after it has been applied once.


To reproduce:

1. Set environment variables as described above

2. apply with depend_list set
```
make tf_apply
```

3. change
in [./terraform/function.tf](./terraform/function.tf) set 

```
depend_list = []
```

4. apply again
```
make tf_apply
```

View result in FunctionGraph console.

5. clean up
```
make tf_destroy
```


## Issue 3 - error if code has not been changed [GitHub Issue 3426](https://github.com/opentelekomcloud/terraform-provider-opentelekomcloud/issues/3426)

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


To reproduce:

1. Set environment variables as described above

2. apply 
```
make tf_apply
```


3. apply again
```
make tf_apply
```

-> error

```
opentelekomcloud_fgs_function_v2.MyFunction: Modifying... [id=urn:fss:eu-de:d52e41d2434941b194ce3f91b1b12f8a:function:default:fg-tf-bug-myfunction:latest]
╷
│ Error: error updating code of function: Bad request with: [PUT https://functiongraph.eu-de.otc.t-systems.com/v2/d52e41d2434941b194ce3f91b1b12f8a/fgs/functions/urn:fss:eu-de:d52e41d2434941b194ce3f91b1b12f8a:function:default:fg-tf-bug-myfunction/code], error message: {
│  "error_code": "FSS.1011",
│  "error_msg": "zip: not a valid zip file",
│  "details": {
│   "error_msg": "Invalid function code."
│  }
│ }
│ 
│   with opentelekomcloud_fgs_function_v2.MyFunction,
│   on function.tf line 4, in resource "opentelekomcloud_fgs_function_v2" "MyFunction":
│    4: resource "opentelekomcloud_fgs_function_v2" "MyFunction" {
│ 
╵
make: *** [Makefile:25: tf_apply] Error 1
```


5. clean up
```
make tf_destroy
```
