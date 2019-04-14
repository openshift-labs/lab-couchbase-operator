---
Title: Operator Prerequisites
PrevPage: ../index
NextPage: 02-creating-the-cluster
---

The couchbase operator is a piece of software that listen for requests and performs standard operations on the database cluster to ensure that the user can focus on usage of the database instead of spending an inordinate amount of time performing adminstration duties.  You can think of OpenShift operators as automative administration software packages.

The Couchbase operator is installed into a project to monitor requests to create a Couchbase cluster. The operator can only be deployed and setup by a cluster admin of the OpenShift cluster.  For this reason, the operator has already been installed into a project that is ready for you to use.

 The user you are running the workshop as, has  been delegated the appropriate roles to allow it to create a Couchbase cluster.

To validate that your user has been granted the appropriate roles, you can use the `oc auth can-i` command to see whether you can create the custom resource definition (CRD) objects the Couchbase operator responds to.

The CRD object you need to create to request the creation of a Couchbase cluster is the `couchbasecluster` object in the `couchbase.com` api group. To check that you can create this, run:

```execute
oc auth can-i create couchbaseclusters.couchbase.com
```

Where the response is `yes`, you have the appropriate role access.

We also need to verify that the Couchbase operator has been deployed into your project. To check this, run:

```execute-1
oc rollout status deployment/couchbase-operator
```

You should see a message:

```
deployment "couchbase-operator" successfully rolled out
```

If the deployment hasn't yet completed, you will see progress messages as it starts up. Wait for the deployment to finish before proceeding.

