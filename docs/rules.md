<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Kubebuilder Rules

<a id="config_map"></a>

## config_map

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "config_map")

config_map(<a href="#config_map-name">name</a>, <a href="#config_map-srcs">srcs</a>, <a href="#config_map-append_hash">append_hash</a>, <a href="#config_map-config_map_name">config_map_name</a>, <a href="#config_map-namespace">namespace</a>)
</pre>

Creates a ConfigMap manifest based on files.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="config_map-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="config_map-srcs"></a>srcs |  A list of source files for the config map. The files' basename will be used as key, using its content as value.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="config_map-append_hash"></a>append_hash |  Append a hash of the configmap to its name.   | Boolean | optional |  `False`  |
| <a id="config_map-config_map_name"></a>config_map_name |  The config map's name   | String | required |  |
| <a id="config_map-namespace"></a>namespace |  The config map's namespace   | String | optional |  `""`  |


<a id="kustomization"></a>

## kustomization

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(<a href="#kustomization-name">name</a>, <a href="#kustomization-resources">resources</a>, <a href="#kustomization-annotations">annotations</a>, <a href="#kustomization-configurations">configurations</a>, <a href="#kustomization-image_tags">image_tags</a>, <a href="#kustomization-labels">labels</a>, <a href="#kustomization-name_prefix">name_prefix</a>,
              <a href="#kustomization-namespace">namespace</a>, <a href="#kustomization-patches">patches</a>, <a href="#kustomization-replacements">replacements</a>, <a href="#kustomization-stamp">stamp</a>)
</pre>

Build a set of KRM resources similar to a kustomization.yaml

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="kustomization-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="kustomization-resources"></a>resources |  Resources to include. Each entry in this list must be a path to a YAML file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="kustomization-annotations"></a>annotations |  Add annotations to add all resources.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="kustomization-configurations"></a>configurations |  A list of transformer configuration files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="kustomization-image_tags"></a>image_tags |  Modify the tags and/or digest for certain images.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="kustomization-labels"></a>labels |  Add labels and optionally selectors to all resources.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="kustomization-name_prefix"></a>name_prefix |  Prepends the value to the names of all resources and references. As namePrefix is self explanatory, it helps adding prefix to names in the defined yaml files.   | String | optional |  `""`  |
| <a id="kustomization-namespace"></a>namespace |  Adds namespace to all resources. Will override the existing namespace if it is set on a resource, or add it if it is not set on a resource.   | String | optional |  `""`  |
| <a id="kustomization-patches"></a>patches |  Patches to be applied to resources. Expects a dictionary of patches to target specs. Keys must be a label to (a) patch file(s), values shall be a JSON string of a target spec.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="kustomization-replacements"></a>replacements |  Substitute field(s) in N target(s) with a field from a source. Replacements are used to copy fields from one source into any number of specified targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="kustomization-stamp"></a>stamp |  Whether to encode build information into the output. Possible values:<br><br>- `stamp = 1`: Always stamp the build information into the output, even in     [--nostamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) builds.     This setting should be avoided, since it is non-deterministic.     It potentially causes remote cache misses for the target and     any downstream actions that depend on the result. - `stamp = 0`: Never stamp, instead replace build information by constant values.     This gives good build result caching. - `stamp = -1`: Embedding of build information is controlled by the     [--[no]stamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) flag.     Stamped targets are not rebuilt unless their dependencies change.   | Integer | optional |  `-1`  |


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


