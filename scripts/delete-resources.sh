#!/bin/bash

set -x
set -eo pipefail

oc delete clusterrole couchbase-operator
oc delete crd couchbaseclusters.couchbase.com
