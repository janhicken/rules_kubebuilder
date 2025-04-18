<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Kubebuilder Rules

<a id="controller_gen_crds"></a>

## controller_gen_crds

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_crds")

controller_gen_crds(<a href="#controller_gen_crds-name">name</a>, <a href="#controller_gen_crds-srcs">srcs</a>, <a href="#controller_gen_crds-allow_dangerous_types">allow_dangerous_types</a>, <a href="#controller_gen_crds-header_file">header_file</a>, <a href="#controller_gen_crds-max_description_length">max_description_length</a>, <a href="#controller_gen_crds-year">year</a>,
                    <a href="#controller_gen_crds-kwargs">kwargs</a>)
</pre>

Generates CustomResourceDefinition objects from Golang struct definitions.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="controller_gen_crds-name"></a>name |  Name of the rule.   |  none |
| <a id="controller_gen_crds-srcs"></a>srcs |  A list of targets that build Go packages used as a source for the generator.   |  none |
| <a id="controller_gen_crds-allow_dangerous_types"></a>allow_dangerous_types |  Allows types which are usually omitted from CRD generation because they are not recommended.   |  `False` |
| <a id="controller_gen_crds-header_file"></a>header_file |  Specifies the header text (e.g. license) to prepend to generated files   |  `None` |
| <a id="controller_gen_crds-max_description_length"></a>max_description_length |  Specifies the maximum description length for fields in CRD's OpenAPI schema.<br><br>`0` indicates drop the description for all fields completely. `n` indicates limit the description to at most `n` characters and truncate the description to closest sentence boundary if it exceeds `n` characters.   |  `-1` |
| <a id="controller_gen_crds-year"></a>year |  Specifies the year to substitute for " YEAR" in the header file<br><br>Currently the following additional types are allowed when this is true: `float32` and `float64`   |  `0` |
| <a id="controller_gen_crds-kwargs"></a>kwargs |  further keyword arguments, e.g. `visibility`   |  none |


<a id="controller_gen_objects"></a>

## controller_gen_objects

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_objects")

controller_gen_objects(<a href="#controller_gen_objects-name">name</a>, <a href="#controller_gen_objects-srcs">srcs</a>, <a href="#controller_gen_objects-header_file">header_file</a>, <a href="#controller_gen_objects-year">year</a>, <a href="#controller_gen_objects-kwargs">kwargs</a>)
</pre>

Generates code containing DeepCopy, DeepCopyInto and DeepCopyObject method implementations.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="controller_gen_objects-name"></a>name |  Name of the rule   |  none |
| <a id="controller_gen_objects-srcs"></a>srcs |  A list of targets that build Go packages used as a source for the generator   |  none |
| <a id="controller_gen_objects-header_file"></a>header_file |  Specifies the header text (e.g. license) to prepend to generated files   |  `None` |
| <a id="controller_gen_objects-year"></a>year |  Specifies the year to substitute for " YEAR" in the header file   |  `0` |
| <a id="controller_gen_objects-kwargs"></a>kwargs |  further keyword arguments, e.g. `visibility`   |  none |


<a id="controller_gen_rbac"></a>

## controller_gen_rbac

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_rbac")

controller_gen_rbac(<a href="#controller_gen_rbac-name">name</a>, <a href="#controller_gen_rbac-srcs">srcs</a>, <a href="#controller_gen_rbac-role_name">role_name</a>, <a href="#controller_gen_rbac-header_file">header_file</a>, <a href="#controller_gen_rbac-year">year</a>, <a href="#controller_gen_rbac-kwargs">kwargs</a>)
</pre>

Generates RBAC manifests from kubebuilder:rbac markers.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="controller_gen_rbac-name"></a>name |  Name of the rule.   |  none |
| <a id="controller_gen_rbac-srcs"></a>srcs |  A list of targets that build Go packages used as a source for the generator.   |  none |
| <a id="controller_gen_rbac-role_name"></a>role_name |  sets the name of the generated ClusterRole   |  none |
| <a id="controller_gen_rbac-header_file"></a>header_file |  Specifies the header text (e.g. license) to prepend to generated files   |  `None` |
| <a id="controller_gen_rbac-year"></a>year |  Specifies the year to substitute for " YEAR" in the header file   |  `0` |
| <a id="controller_gen_rbac-kwargs"></a>kwargs |  further keyword arguments, e.g. `visibility`   |  none |


<a id="controller_gen_webhooks"></a>

## controller_gen_webhooks

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_webhooks")

controller_gen_webhooks(<a href="#controller_gen_webhooks-name">name</a>, <a href="#controller_gen_webhooks-srcs">srcs</a>, <a href="#controller_gen_webhooks-header_file">header_file</a>, <a href="#controller_gen_webhooks-year">year</a>, <a href="#controller_gen_webhooks-kwargs">kwargs</a>)
</pre>

Generates (partial) {Mutating,Validating}WebhookConfiguration objects.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="controller_gen_webhooks-name"></a>name |  Name of the rule.   |  none |
| <a id="controller_gen_webhooks-srcs"></a>srcs |  A list of targets that build Go packages used as a source for the generator.   |  none |
| <a id="controller_gen_webhooks-header_file"></a>header_file |  Specifies the header text (e.g. license) to prepend to generated files   |  `None` |
| <a id="controller_gen_webhooks-year"></a>year |  Specifies the year to substitute for " YEAR" in the header file   |  `0` |
| <a id="controller_gen_webhooks-kwargs"></a>kwargs |  further keyword arguments, e.g. `visibility`   |  none |


<a id="envtest_test"></a>

## envtest_test

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "envtest_test")

envtest_test(<a href="#envtest_test-name">name</a>, <a href="#envtest_test-envtest_repo">envtest_repo</a>, <a href="#envtest_test-kwargs">kwargs</a>)
</pre>

Configures a go_test with envtest binaries

The envtest binaries will be available at runtime.
The path to the binary directory will be available through the environment variable KUBEBUILDER_ASSETS.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="envtest_test-name"></a>name |  Name of the rule   |  none |
| <a id="envtest_test-envtest_repo"></a>envtest_repo |  Name of the envtest repository to use   |  `"@envtest"` |
| <a id="envtest_test-kwargs"></a>kwargs |  further keyword arguments forwarded to go_test   |  none |


