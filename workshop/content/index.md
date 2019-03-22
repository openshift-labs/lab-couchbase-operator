---
Sort: 1
Title: Workshop Overview
NextPage: exercises/01-operator-prerequisites
ExitSign: Start Workshop
---

Check Couchbase operator is deployed.

```execute-1
oc rollout status deployment/couchbase-operator
```

Create secret to be used for Couchbase cluster.

```execute-1
oc apply -f couchbase/secret.yaml
```

Set up a watch of pods created for the Couchbase cluster.

```execute-2
oc get pods -l couchbase_cluster=cb-example --watch
```

Create the Couchbase cluster.

```execute-1
oc apply -f couchbase/couchbase-cluster.yaml
```

Wait for all three pods to be created, one for each replica, then kill the watch.

```execute-2
<ctrl+c>
```
