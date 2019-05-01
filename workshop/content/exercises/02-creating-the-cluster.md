---
Title: Creating the Cluster
PrevPage: 01-operator-prerequisites
NextPage: 03-exposing-console
---

One of the first things we need to do is provide authentication information for the couchbase cluster.  This information is provided as a secret on the OpenShift platform. The yaml for creating this secret has been provided for you as part of the lab.  Let's take a look at it:

```execute-1
cat couchbase/secret.yaml
```

You will notice the following stanza:
    
    data:
        username: QWRtaW5pc3RyYXRvcg==
        password: cGFzc3dvcmQ=

Keep in mind that the username and password are base 64 encoded.  The decoded valued are "Administrator" and "password".  You can verify this by running the following commands:

```execute-1
echo $(grep username couchbase/secret.yaml | sed 's/  username: //' | base64 --decode)
```

```execute-1
echo $(grep password couchbase/secret.yaml | sed 's/  password: //' | base64 --decode)
```


Create secret to be used for Couchbase cluster.

```execute-1
oc apply -f couchbase/secret.yaml
```

Now we can set up a watch of the pods created for the Couchbase cluster so that we can monitor progress as we perform commands.

```execute-2
watch oc get pods -l couchbase_cluster=cb-example
```

Now that we have our watch setup, it's time to actually deploy the couchbase cluster. The cluster configuration parameters have been provided for this lab.  Let's take a look at them now:

```execute-1
cat couchbase/couchbase-cluster.yaml
```

    apiVersion: couchbase.com/v1
        kind: CouchbaseCluster
        metadata:
        name: cb-example
        spec:
        baseImage: couchbase/server
        version: 6.0.1
        authSecret: cb-example-auth
        exposeAdminConsole: true
        adminConsoleServices:
            - data
        cluster:
            dataServiceMemoryQuota: 256
            indexServiceMemoryQuota: 256
            searchServiceMemoryQuota: 256
            eventingServiceMemoryQuota: 256
            analyticsServiceMemoryQuota: 1024
            indexStorageSetting: memory_optimized
            autoFailoverTimeout: 120
            autoFailoverMaxCount: 3
            autoFailoverOnDataDiskIssues: true
            autoFailoverOnDataDiskIssuesTimePeriod: 120
            autoFailoverServerGroup: false
        buckets:
            - name: default
            type: couchbase
            memoryQuota: 128
            replicas: 1
            ioPriority: high
            evictionPolicy: fullEviction
            conflictResolution: seqno
            enableFlush: true
            enableIndexReplica: false
        servers:
            - size: 3
            name: all_services
            services:
                - data
                - index
                - query
                - search
                - eventing
                - analytics

A few important things to note in the above configuration is the name of the auth secret (cb-example-auth) being used and the size of the cluster (3). Once you have examined the configuration, let's create the cluster by applying the configuration with the `oc apply` command:

```execute-1
oc apply -f couchbase/couchbase-cluster.yaml
```

Wait for all three pods to be created and go into a *READY* and *RUNNING* state, one for each replica, then kill the watch. This can take a minute or two.

```execute-2
<ctrl+c>
```
