# OpenShift4 Offline Operator Catalog Build and Mirror

> :heavy_exclamation_mark: *Red Hat support cannot assist with problems with this Repo*. For issues please open a GitHub issue.

This script will create a custom operator catalog based on the desired operators and mirror the images to a local registry, useful for air-gapped (disconnected) or restricted networks.  Tested with OpenShift 4.6.

What is the purpose of this?

Because the current catalog build and mirror (https://docs.openshift.com/container-platform/4.6/operators/olm-restricted-networks.html) takes 1-5 hours to create and more than 50% of the catalog is not usable offline anyways. This tool allows you to create a custom catalog with only the operators you need/want.


## Requirements

It is assumed you already have a registry setup locally to mirror operator content to.  See the section Local Docker Registry for an example implementation.

This tool was tested with the following versions of the runtime and utilities:

1. RHEL 8.2
2. Python 3.6.8 (with pyyaml,jinja2 library)
3. Podman v1.9.3 (If you use anything below 1.8, you might run into issues with multi-arch manifests)
4. Skopeo 1.0.0 (If you use anything below 1.0 you might have issue with the newer manifests)

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
5. Login to quay.io using podman
6. Update the offline-operator-list file with the operators you want to include in the catalog creation and mirroring. See <https://access.redhat.com/articles/4740011> for list of supported offline operators
7. Run the script (sample command, see Script Arguments section for more details)

```Shell
mirror-operator-catalog.py \
--authfile ../../pull-secret-full.json \
--registry-olm bastion.example.com:5000/ocp4/openshift4 \
--registry-catalog bastion.example.com:5000/ocp4/openshift4 \
--operator-file offline-operator-list \
```

7. Disable default operator source
```Shell
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```
8. Apply the yaml files in the `publish` folder. The image content source policy will create a new MCO render which will start a rolling reboot of your cluster nodes. You have to wait until that is complete before attempting to install operators from the catalog.


##### Script Arguments

###### --catalog-version

Arbitrary version number to tag your catalog image. Unless you are interested in doing A/B testing, keep the release version for all subsequent runs.


###### --authfile

The location of the auth.json file generated when you use podman or docker to login registries using podman. You can use the `pull-secret.json` that contains JSON formatted logins if you have it, which also should include your local registry information and login auth hash. Otherwise, the auth file is located either in your home directory under .docker or /run/user/your_uid/containers/auth.json or /var/run/containers/your_uid/auth.json


###### --registry-olm

The URL of the destination registry where the operator images will be mirrored to.


###### --registry-catalog

The URL of the destination registry where the operator catalog image will be published to.


###### --operator-file

Location of the file containing a list of operators to include in your custom catalog. The entries should be in plain text with no quotes. Each line should only have one operator name. 

Example:

```Shell
container-security-operator,latest
performance-addon-operator,7.0.0
```

## Updating The Catalogue

To update the catalog,run the script the same way you did the first time and increment the catalog-version. An updated Catalogue image will be created. Afterwards do an `oc apply -f rh-catalog-source.yaml` to update the catalogsource with the new image.

## Script Notes

Unfortunately, just because an image is listed in the related images spec doesn't mean it exists or is even used by the operator. for example `registry.redhat.io/openshift4/ose-promtail` from the logging operator. Tthat image is put in the knownBadImages file to avoid attempting to mirror.

## Local Docker Registry

If you need a to create a local secured registry, follow the instructions from this link:
<https://docs.openshift.com/container-platform/4.6/installing/install_config/installing-restricted-networks-preparations.html#installing-restricted-networks-preparations>

## Acknowledgements

This work was heavily borrowed from Red Hat Consulting customer efforts (names obfuscated) and Mr. Arvin Amirian.
