#!/bin/bash

set -x
set -eo pipefail

WORKSHOP_NAME=lab-couchbase-operator
JUPYTERHUB_APPLICATION=${JUPYTERHUB_APPLICATION:-couchbase-lab}
JUPYTERHUB_NAMESPACE=`oc project --short`

oc delete all --selector build="$WORKSHOP_NAME"
