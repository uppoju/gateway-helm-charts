#!/bin/bash
# This script connects to a gce cluster and install helm tiller on it. Example
# .\instal-tiller.sh cluster=apim-kubernetes-dev1 region=us-west2 project=api-management-178215
# where project is optional argument with a default value of api-management-178215
# while cluster and region are required arguments
echo "Usage: ./install-tiller.sh cluster=cluster_name region=cluster_region [project=project_name]"

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            project)             project=${VALUE} ;;
            cluster)             cluster=${VALUE} ;;
            region)              region=${VALUE} ;;
            *)
    esac
done

if test -z "${cluster}"
then
	echo "Cluster name must be specified"
	exit 1
fi

if test -z "${region}"
then
	echo "Region must be specified"
	exit 1
fi

if test -z "${project}"
then
	project="api-management-178215"
fi

#Get credentials and connect to specific Kubernetes cluster
gcloud beta container clusters get-credentials $cluster --region $region --project $project > /dev/null
if [ $? -eq 0 ]; then
    echo Connected to cluster.
else
    echo Failed to connected to cluster.
    exit 1
fi

#Add a service account in the kube-system namespace for Tiller to use
TILLER_EXISTS=$(kubectl get serviceAccounts --namespace kube-system | grep tiller | wc -l)
if [ $TILLER_EXISTS == "0" ]
then
    kubectl --namespace kube-system create sa tiller > /dev/null
    if [ $? -eq 0 ]; then
        echo Tiller service account added.
    else
        echo Failed to create tiller account.
        exit 1
    fi
else echo "Tiller account already exists."
fi

#Create a cluster role binding for the service account to grant Tiller cluster admin privileges
ROLE_EXISTS=$(kubectl get clusterrolebinding | grep tiller | wc -l)
if [ $ROLE_EXISTS == "0" ]
then
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller > /dev/null
    if [ $? -eq 0 ]; then
        echo Tiller cluster role added.
    else
        echo Failed to create tiller role.
        exit 1
    fi
else echo "Tiller role already exists."
fi

#Initialize helm using the tiller service account
helm init --service-account tiller > /dev/null
if [ $? -eq 0 ]; then
    echo Helm initialized.
else
    echo Failed to initialize helm.
    exit 1
fi

#Update the local repo for your Helm installation
helm repo update > /dev/null
if [ $? -eq 0 ]; then
    echo Local repo updated.
else
    echo Failed to update local repo.
    exit 1
fi