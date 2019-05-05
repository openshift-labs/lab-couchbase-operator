---
Title: Exposing the Console
PrevPage: 02-creating-the-cluster
NextPage: 04-using-console
---

Now that the Couchbase cluster has been deployed, let's take a look at the console for administration of the cluster. In order to access the console, we first need to find and expose the Kubernetes service for the UI.  

```execute-1
oc get svc
```

You should see the following output:

```
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
        AGE
cb-example       ClusterIP   None            <none>        8091/TCP,18091/TCP
        3m
cb-example-srv   ClusterIP   None            <none>        11210/TCP,11207/TCP
        3m
cb-example-ui    NodePort    172.30.44.247   <none>        8091:32711/TCP,18091:314
45/TCP   3m
```

The service that exposes the web console is called `cb-example-ui`.  To expose this service, we simply need to use the `oc expose` command passing in the name of the service.

```execute-1
oc expose svc/cb-example-ui
```

We can then view the URL get issuing the `oc get routes` command:

```execute-1
oc get routes
```

You should see output like the following:

```
NAME            HOST/PORT                                                 PATH
SERVICES        PORT        TERMINATION   WILDCARD
cb-example-ui   cb-example-ui-%project_namespace%.%cluster_subdomain%
cb-example-ui   couchbase                 None
```

In the above example, the URL is:

http://cb-example-ui-%project_namespace%.%cluster_subdomain%

This can also be [viewed](%console_url%/k8s/ns/%project_namespace%/routes) in the OpenShift web console. Click on the console tab to switch to the browser view.

![Console Tab](console-tab.png)

Next, expand the *Networking* tab and then click on *Routes*. This will show the route which was created.

![Network Route](console-routes.png)

Go ahead and click on the route under the *Location* column in the web console to open up the Couchbase web console in a new browser tab.
