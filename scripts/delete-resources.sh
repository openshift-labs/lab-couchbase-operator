#!/bin/bash

set -x

oc delete clusterrole couchbase-operator
oc delete crd couchbaseclusters.couchbase.com
