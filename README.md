# OpenShift4 Offline Operator Catalog Build and Mirror

> :heavy_exclamation_mark: *Red Hat support cannot assist with problems with this Repo*.

This script will create a custom operator catalog based on the desired operators and mirror the images to a local registry, useful for air-gapped (disconnected) or restricted networks.  Tested with OpenShift 4.6.1.

What is the purpose of this?

Because the current catalog build and mirror (https://docs.openshift.com/container-platform/4.6/operators/olm-restricted-networks.html) takes 1-5 hours to create and more than 50% of the catalog is not usable offline anyways. This tool allows you to create a custom catalog with only the operators you need/want.


## Prerequisites
Be sure you have registry authentication tokens setup, it makes life easier.
https://access.redhat.com/RegistryAuthentication
https://access.redhat.com/terms-based-registry/


## Requirements

It is assumed you already have a registry setup locally to mirror operator content to.  See the section Local Docker Registry for an example implementation.

This tool was tested with the following versions of the runtime and utilities:

1. RHEL 8.2
2. Podman v1.9.3 (If you use anything below 1.8, you might run into issues with multi-arch manifests)
3. Skopeo 1.0.0 (If you use anything below 1.0 you might have issue with the newer manifests)
4. OPM CLI
  - oc image extract registry.redhat.io/openshift4/ose-operator-registry:v4.6 --registry-config='~/openshift/pull-secret-full.json' --path /usr/bin/opm:. --confirm
  - sudo chmod +x opm
  - sudo mv opm /usr/local/bin

Please note this ideally works best with operators that meet the following criteria:

1. Have a ClusterServiceVersion (CSV) in the manifest that contains a full list of related images
2. The related images are tagged with a SHA

For a full list of operators that work offline please see link below
<https://access.redhat.com/articles/4740011>

## Running the script

1. `git clone` this repository
2. Install the tools listed in the requirements section
3. Login to your offline registry using podman (This is the registry where you will be publishing the catalog and related images)
4. Login to registry.redhat.io using podman
5. Modify variables to suit your environment in the script olm-operator-4.6.sh.
6. Launch the script. See <https://access.redhat.com/articles/4740011> for list of supported offline operators.

```Shell
./olm-operator-4.6.sh
```

7. Disable default operator source
```Shell
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```
8. Apply the two yaml files in the `redhat-operator-index-manifests` folder via `oc apply -f`. The image content source policy will create a new MCO render, which will start a rolling reboot of your cluster nodes. You have to wait until that is complete before attempting to install operators from the catalog.


## Script Notes

Placeholders have been left for other Operator catalogs.

## Local Docker Registry

If you need a to create a local secured registry, follow the instructions from this link:
<https://docs.openshift.com/container-platform/4.6/installing/install_config/installing-restricted-networks-preparations.html#installing-restricted-networks-preparations>

## Acknowledgements

PRs welcome!
