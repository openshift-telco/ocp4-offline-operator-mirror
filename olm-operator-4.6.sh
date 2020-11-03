#!/bin/bash -e
# Variables to set, suit to your installation
export OCP_RELEASE=4.6
export OCP_PULLSECRET_AUTHFILE='../pull-secret-full.json'
export LOCAL_REGISTRY=registry.pod2.dcain.lab:5000
export LOCAL_REGISTRY_INDEX_TAG=olm-index/redhat-operator-index:v$OCP_RELEASE
export LOCAL_REGISTRY_IMAGE_TAG=olm

# Set these values to true for the catalog and miror to be created
export RH_OP='true'
export CERT_OP='false'
export COMM_OP='false'
export MARKETPLACE_OP='false'

export RH_OP_INDEX="registry.redhat.io/redhat/redhat-operator-index:v${OCP_RELEASE}"
export CERT_OP_INDEX="registry.redhat.io/redhat/certified-operator-index:v${OCP_RELEASE}"
export COMM_OP_INDEX="registry.redhat.io/redhat/community-operator-index:v${OCP_RELEASE}"
export MARKETPLACE_OP_INDEX="registry.redhat.io/redhat-marketplace-index:v${OCP_RELEASE}"
export RH_OP_PACKAGES='advanced-cluster-management,cluster-logging,local-storage-operator,performance-addon-operator,ptp-operator,sriov-network-operator'

# Mirror redhat-operator index image
if [ "${RH_OP}" = true ]
  then
    opm index prune --from-index $RH_OP_INDEX --packages $RH_OP_PACKAGES --tag $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG
    podman push $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG --authfile $OCP_PULLSECRET_AUTHFILE
    oc adm catalog mirror $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG $LOCAL_REGISTRY/$LOCAL_REGISTRY_IMAGE_TAG --registry-config=$OCP_PULLSECRET_AUTHFILE

    echo "apiVersion: operators.coreos.com/v1alpha1" > redhat-operator-index-manifests/catalogsource.yaml
    echo "kind: CatalogSource" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "metadata:" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "  name: my-operator-catalog" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "  namespace: openshift-marketplace" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "spec:" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "  sourceType: grpc" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "  image: $LOCAL_REGISTRY/$LOCAL_REGISTRY_INDEX_TAG" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "  displayName: Altiostar Temp Lab" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "  publisher: altiostar" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "  updateStrategy:" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "    registryPoll:" >> redhat-operator-index-manifests/catalogsource.yaml
    echo "      interval: 30m" >> redhat-operator-index-manifests/catalogsource.yaml

    echo ""
    echo "To apply the Red Hat Operators catalog mirror configuration to your cluster, do the following:"
    echo "oc apply -f ./redhat-operator-index-manifests/imageContentSourcePolicy.yaml"  
    echo "oc apply -f ./redhat-operator-index-manifests/catalogsource.yaml"  
fi

if [ "${CERT_OP}" = true ]
  then
    "echo 1"
fi  
  
if [ "${COMM_OP}" = true ]
  then
    "echo 2"
fi 

if [ "${MARKETPLACE_OP}" = true ]
  then
    "echo 3"
fi 

exit 0
