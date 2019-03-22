---
Sort: 2
Title: Installing the Operator
---

Before this workshop can be used in an OpenShift cluster, a cluster role and custom resource definitions for the Couchbase operator must first be created. The Couchbase operator itself is not installed, as that needs to be deployed to each project where it is required. It cannot be installed globally to monitor all projects.

The steps below are not part of what a developer wanting to deploy a Couchbase cluster needs to do, and they are not displayed as part of the workshop steps. The steps below will need though to be run once by someone with cluster admin access to the OpenShift cluster.

For original details on installing the Couchbase operator, see the documentation at:

* https://docs.couchbase.com/operator/1.1/overview.html

Note that the instructions here, and the files used from the Couchbase operator package, may have been customised because of how the workshop environment works.

### Login as a cluster admin

The workshop when deployed through the learning portal configuration provides a session using a service account with limited access to a single project. To setup the Couchbase operator, you will need to login to the OpenShift cluster as a user with cluster admin access. For RHPDS, this will be the `opentlc-mgr` user.

```execute
oc login
```

### Create a cluster role

The Couchbase operator will be deployed to each project where a Couchbase cluster is to be created. It will need specific roles to access resources it needs. Create a global cluster role definition. This will later be applied to a service account created in each project, where the Couchbase operator runs as that service account.

```execute
oc apply -f couchbase/cluster-role-sa.yaml
```

### Create custom resource definitions

The Couchbase operator is controlled through custom resource definitions (CRDs), but although the operator is deployed in each project it is to be used, the CRDs must be installed globally.

```execute
oc apply -f couchbase/crd.yaml
```

### Grant users Couchbase admin rights

The service account a user works through, when a workshop is deployed through the learning portal configuration, will not have any ability to create Couchbase clusters. This is because by default, only cluster admins can create the required custom resource definitions that will trigger the creation of a Couchbase cluster. In order that a workshop user when using this configuration can create Couchbase clusters, they need to be granted additional cluster roles.

Presuming that the workshop is already deployed through the learning portal configuration, and additional cluster policy rules have not been added, run:

```execute
oc patch clusterrole %jupyterhub_application%-%jupyterhub_namespace%-session-rules --patch '
rules:
- apiGroups:
  - couchbase.com
  resources:
  - couchbaseclusters
  verbs:
  - "*"
'
```

### Installation of the operator

The Couchbase operator needs to be deployed into the project for each user doing the workshop. Rather than the user doing this, it will be created automatically when the project is created. To do this, the list of extra resources to create in each project needs to be defined. To add these run:

```execute
oc patch configmap %jupyterhub_application%-cfg -n %jupyterhub_namespace% --patch '
data:
  extra_resources.json: |-
    {
      "kind": "List",
      "apiVersion": "v1",
      "items": [
        {
          "kind": "ServiceAccount",
          "apiVersion": "v1",
          "metadata": {
            "name": "couchbase-operator"
          }
        },
        {
          "kind": "RoleBinding",
          "apiVersion": "rbac.authorization.k8s.io/v1beta1",
          "metadata": {
            "name": "couchbase-operator-rolebinding"
          },
          "subjects": [
            {
              "kind": "ServiceAccount",
              "name": "couchbase-operator",
              "namespace": "${project_namespace}"
            }
          ],
          "roleRef": {
            "apiGroup": "rbac.authorization.k8s.io",
            "kind": "ClusterRole",
            "name": "couchbase-operator"
          }
        },
        {
          "apiVersion": "apps/v1",
          "kind": "Deployment",
          "metadata": {
            "name": "couchbase-operator"
          },
          "spec": {
            "replicas": 1,
            "selector": {
              "matchLabels": {
                "app": "couchbase-operator"
              }
            },
            "template": {
              "metadata": {
                "labels": {
                  "app": "couchbase-operator"
                }
              },
              "spec": {
                "containers": [
                  {
                    "name": "couchbase-operator",
                    "image": "couchbase/operator:1.1.0",
                    "command": [
                      "couchbase-operator"
                    ],
                    "args": [
                      "-enable-upgrades=false"
                    ],
                    "env": [
                      {
                        "name": "MY_POD_NAMESPACE",
                        "valueFrom": {
                          "fieldRef": {
                            "fieldPath": "metadata.namespace"
                          }
                        }
                      },
                      {
                        "name": "MY_POD_NAME",
                        "valueFrom": {
                          "fieldRef": {
                            "fieldPath": "metadata.name"
                          }
                        }
                      }
                    ],
                    "ports": [
                      {
                        "name": "readiness-port",
                        "containerPort": 8080
                      }
                    ],
                    "readinessProbe": {
                      "httpGet": {
                        "path": "/readyz",
                        "port": "readiness-port"
                      },
                      "initialDelaySeconds": 3,
                      "periodSeconds": 3,
                      "failureThreshold": 19
                    }
                  }
                ],
                "serviceAccountName": "couchbase-operator"
              }
            }
          }
        }
      ]
    }
'
```

As the resources include cluster role bindings, we need to update the policy rules for the spawner cluster role so it can binding those cluster roles against the service account in the project.
 
```execute
oc patch clusterrole %jupyterhub_application%-%jupyterhub_namespace%-spawner-rules --patch '
rules:
- apiGroups:
  - ""
  - authorization.openshift.io
  - rbac.authorization.k8s.io
  resourceNames:
  - couchbase-operator
  resources:
  - clusterroles
  verbs:
  - bind
'
```

### Restarting the workshop spawner

You will now need to restart the learning portal to pick up the new roles. This will cause this workshop session to be killed, so you will need to restart to test the result.

```execute
oc rollout latest %jupyterhub_application% -n %jupyterhub_namespace%
```
