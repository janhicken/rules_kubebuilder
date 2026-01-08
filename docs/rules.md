<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Kubebuilder Rules

<a id="chainsaw_test"></a>

## chainsaw_test

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "chainsaw_test")

chainsaw_test(<a href="#chainsaw_test-name">name</a>, <a href="#chainsaw_test-srcs">srcs</a>, <a href="#chainsaw_test-kind_env">kind_env</a>)
</pre>

Define a Chainsaw test that runs on a kind cluster.

Please remember to set the tag `supports-graceful-termination` on the target to allow the test runner to export the
kind cluster's logs and shut it down.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="chainsaw_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="chainsaw_test-srcs"></a>srcs |  YAML file(s) that make(s) up the Chainsaw test.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="chainsaw_test-kind_env"></a>kind_env |  The kind environment to run the tests in.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


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


<a id="generic_secret"></a>

## generic_secret

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "generic_secret")

generic_secret(<a href="#generic_secret-name">name</a>, <a href="#generic_secret-srcs">srcs</a>, <a href="#generic_secret-append_hash">append_hash</a>, <a href="#generic_secret-namespace">namespace</a>, <a href="#generic_secret-secret_name">secret_name</a>)
</pre>

Creates a secret manifest based on files.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="generic_secret-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="generic_secret-srcs"></a>srcs |  A list of source files for the secret. The files' basename will be used as key, using its content as value.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="generic_secret-append_hash"></a>append_hash |  Append a hash of the secret to its name.   | Boolean | optional |  `False`  |
| <a id="generic_secret-namespace"></a>namespace |  The secret's namespace   | String | optional |  `""`  |
| <a id="generic_secret-secret_name"></a>secret_name |  The secret's name   | String | required |  |


<a id="kind_env"></a>

## kind_env

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kind_env")

kind_env(<a href="#kind_env-name">name</a>, <a href="#kind_env-cluster_name">cluster_name</a>, <a href="#kind_env-images">images</a>, <a href="#kind_env-kustomization">kustomization</a>)
</pre>

Creates a local dev environment with kind using the given kustomization and images.

The container images downloaded by containerd will be stored in a dedicated Docker volume attached to the kind node.
All clusters with the same name created by this rule will share the same volume.
This way, container images do not have to be re-downloaded every time the cluster is started.

A kubeconfig for the cluster will be written to a filed named `${cluster_name}-kubeconfig.yaml` in the workspace root.
If the environment variable `KUBECONFIG` is set, it will be written to that path instead.

Running the rule multiple times is idempotent.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="kind_env-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="kind_env-cluster_name"></a>cluster_name |  The kind cluster name.   | String | required |  |
| <a id="kind_env-images"></a>images |  OCI image tarballs to load into the kind cluster.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="kind_env-kustomization"></a>kustomization |  Kustomization to apply to the cluster.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="kustomization"></a>

## kustomization

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "kustomization")

kustomization(<a href="#kustomization-name">name</a>, <a href="#kustomization-resources">resources</a>, <a href="#kustomization-annotations">annotations</a>, <a href="#kustomization-config_maps">config_maps</a>, <a href="#kustomization-configurations">configurations</a>, <a href="#kustomization-image_digests">image_digests</a>, <a href="#kustomization-image_names">image_names</a>,
              <a href="#kustomization-image_tags">image_tags</a>, <a href="#kustomization-labels">labels</a>, <a href="#kustomization-name_prefix">name_prefix</a>, <a href="#kustomization-name_suffix">name_suffix</a>, <a href="#kustomization-namespace">namespace</a>, <a href="#kustomization-patches">patches</a>, <a href="#kustomization-replacements">replacements</a>, <a href="#kustomization-stamp">stamp</a>)
</pre>

Build a set of KRM resources similar to a kustomization.yaml.

All attributes support interpolation of stamp variables, if stamping is enabled.
The stamp variable needs to be referenced using the syntax like `${STABLE_VAR_NAME}` or `${BUILD_TIMESTAMP}`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="kustomization-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="kustomization-resources"></a>resources |  Resources to include. Each entry in this list must be a path to a YAML file.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="kustomization-annotations"></a>annotations |  Add annotations to add all resources.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="kustomization-config_maps"></a>config_maps |  Create ConfigMaps from files. The key will be the config map's name, the value is a set of files from which the data shall be sourced.   | Dictionary: String -> Label | optional |  `{}`  |
| <a id="kustomization-configurations"></a>configurations |  A list of transformer configuration files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="kustomization-image_digests"></a>image_digests |  Inject digest references for images (key) based on the OCI image digests (value). Values must be labels to a `.digest` target created by _rules_oci_'s `oci_image` or `oci_image_index` macros.   | Dictionary: String -> Label | optional |  `{}`  |
| <a id="kustomization-image_names"></a>image_names |  Modify the names for certain images.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="kustomization-image_tags"></a>image_tags |  Modify the tags for certain images.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="kustomization-labels"></a>labels |  Add labels and optionally selectors to all resources.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="kustomization-name_prefix"></a>name_prefix |  Prepends the value to the names of all resources and references. As namePrefix is self explanatory, it helps adding prefix to names in the defined yaml files.   | String | optional |  `""`  |
| <a id="kustomization-name_suffix"></a>name_suffix |  Appends the value to the names of all resources and references. As nameSuffix is self explanatory, it helps adding suffix to names in the defined yaml files.   | String | optional |  `""`  |
| <a id="kustomization-namespace"></a>namespace |  Adds namespace to all resources. Will override the existing namespace if it is set on a resource, or add it if it is not set on a resource.   | String | optional |  `""`  |
| <a id="kustomization-patches"></a>patches |  Patches to be applied to resources. Expects a dictionary of patches to target specs. Keys must be a label to (a) patch file(s), values shall be a JSON string of a target spec.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="kustomization-replacements"></a>replacements |  Substitute field(s) in N target(s) with a field from a source. Replacements are used to copy fields from one source into any number of specified targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="kustomization-stamp"></a>stamp |  Whether to encode build information into the output. Possible values:<br><br>- `stamp = 1`: Always stamp the build information into the output, even in     [--nostamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) builds.     This setting should be avoided, since it is non-deterministic.     It potentially causes remote cache misses for the target and     any downstream actions that depend on the result. - `stamp = 0`: Never stamp, instead replace build information by constant values.     This gives good build result caching. - `stamp = -1`: Embedding of build information is controlled by the     [--[no]stamp](https://docs.bazel.build/versions/main/user-manual.html#flag--stamp) flag.     Stamped targets are not rebuilt unless their dependencies change.   | Integer | optional |  `-1`  |


<a id="tls_secret"></a>

## tls_secret

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "tls_secret")

tls_secret(<a href="#tls_secret-name">name</a>, <a href="#tls_secret-append_hash">append_hash</a>, <a href="#tls_secret-cert">cert</a>, <a href="#tls_secret-key">key</a>, <a href="#tls_secret-namespace">namespace</a>, <a href="#tls_secret-secret_name">secret_name</a>)
</pre>

Creates a TLS secret manifest from the given public/private key pair.

The public/private key pair must exist beforehand. The public key certificate must be PEM-encoded and match the given
private key.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="tls_secret-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="tls_secret-append_hash"></a>append_hash |  Append a hash of the secret to its name.   | Boolean | optional |  `False`  |
| <a id="tls_secret-cert"></a>cert |  Label to PEM-encoded public key certificate   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="tls_secret-key"></a>key |  Label to private key associated with the given certificate   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="tls_secret-namespace"></a>namespace |  The secret's namespace   | String | optional |  `""`  |
| <a id="tls_secret-secret_name"></a>secret_name |  The secret's name   | String | required |  |


<a id="controller_gen_crds"></a>

## controller_gen_crds

<pre>
load("@io_github_janhicken_rules_kubebuilder//kubebuilder:defs.bzl", "controller_gen_crds")

controller_gen_crds(<a href="#controller_gen_crds-name">name</a>, <a href="#controller_gen_crds-srcs">srcs</a>, <a href="#controller_gen_crds-allow_dangerous_types">allow_dangerous_types</a>, <a href="#controller_gen_crds-header_file">header_file</a>, <a href="#controller_gen_crds-max_description_length">max_description_length</a>, <a href="#controller_gen_crds-year">year</a>,
                    <a href="#controller_gen_crds-kwargs">**kwargs</a>)
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

controller_gen_objects(<a href="#controller_gen_objects-name">name</a>, <a href="#controller_gen_objects-srcs">srcs</a>, <a href="#controller_gen_objects-header_file">header_file</a>, <a href="#controller_gen_objects-year">year</a>, <a href="#controller_gen_objects-kwargs">**kwargs</a>)
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

controller_gen_rbac(<a href="#controller_gen_rbac-name">name</a>, <a href="#controller_gen_rbac-srcs">srcs</a>, <a href="#controller_gen_rbac-role_name">role_name</a>, <a href="#controller_gen_rbac-header_file">header_file</a>, <a href="#controller_gen_rbac-year">year</a>, <a href="#controller_gen_rbac-kwargs">**kwargs</a>)
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

controller_gen_webhooks(<a href="#controller_gen_webhooks-name">name</a>, <a href="#controller_gen_webhooks-srcs">srcs</a>, <a href="#controller_gen_webhooks-header_file">header_file</a>, <a href="#controller_gen_webhooks-year">year</a>, <a href="#controller_gen_webhooks-kwargs">**kwargs</a>)
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

envtest_test(<a href="#envtest_test-name">name</a>, <a href="#envtest_test-envtest_repo">envtest_repo</a>, <a href="#envtest_test-kwargs">**kwargs</a>)
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


