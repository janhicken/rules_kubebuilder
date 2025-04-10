<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Kubebuilder Rules

<a id="controller_gen_crds"></a>

## controller_gen_crds

<pre>
controller_gen_crds(<a href="#controller_gen_crds-name">name</a>, <a href="#controller_gen_crds-srcs">srcs</a>, <a href="#controller_gen_crds-kwargs">kwargs</a>)
</pre>

Generates CustomResourceDefinition objects from Golang struct definitions.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="controller_gen_crds-name"></a>name |  Name of the rule.   |  none |
| <a id="controller_gen_crds-srcs"></a>srcs |  A list of targets that build Go packages used as a source for the generator.   |  none |
| <a id="controller_gen_crds-kwargs"></a>kwargs |  further keyword arguments, e.g. `visibility`   |  none |


<a id="controller_gen_rbac"></a>

## controller_gen_rbac

<pre>
controller_gen_rbac(<a href="#controller_gen_rbac-name">name</a>, <a href="#controller_gen_rbac-srcs">srcs</a>, <a href="#controller_gen_rbac-role_name">role_name</a>, <a href="#controller_gen_rbac-kwargs">kwargs</a>)
</pre>

Generates RBAC manifests from kubebuilder:rbac markers.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="controller_gen_rbac-name"></a>name |  Name of the rule.   |  none |
| <a id="controller_gen_rbac-srcs"></a>srcs |  A list of targets that build Go packages used as a source for the generator.   |  none |
| <a id="controller_gen_rbac-role_name"></a>role_name |  sets the name of the generated ClusterRole   |  none |
| <a id="controller_gen_rbac-kwargs"></a>kwargs |  further keyword arguments, e.g. `visibility`   |  none |


