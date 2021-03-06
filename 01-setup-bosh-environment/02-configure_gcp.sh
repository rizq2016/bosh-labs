#!/bin/bash
set -e

SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME:-baselbosh}

GCP_PROJECT=$DEVSHELL_PROJECT_ID

# Initial setup
# Name to use for GCP service account specific to this environment.
SERVICE_ACCOUNT_NAME=${SERVICE_ACCOUNT_NAME}

set +e
  ## Check for account existance
  gcloud iam service-accounts list --format json|jq -r '.[]|.email'|grep "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com"
  if [ $? != 0 ]; then
    echo
    echo "Creating GCP service account..."
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name "Altoros Automation"
    gcloud projects add-iam-policy-binding "$GCP_PROJECT" --member "serviceAccount:$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com" --role "roles/editor"
    gcloud iam service-accounts keys create "$SERVICE_ACCOUNT_NAME.key.json" --iam-account "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com"
  else
    grep "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com" "$SERVICE_ACCOUNT_NAME.key.json"
    if [ $? != 0 ]; then
      # if service account name changed
      gcloud iam service-accounts keys create "$SERVICE_ACCOUNT_NAME.key.json" --iam-account "$SERVICE_ACCOUNT_NAME@$GCP_PROJECT.iam.gserviceaccount.com"
      echo "Not recreating account, but added new keys"
    else
      echo "Account already created, not creating or adding more keys to account"
    fi
  fi
set -e

mkdir -p `pwd`/bbl-state
echo export BBL_STATE_DIRECTORY=`pwd`/bbl-state >> ~/.bashrc
echo export BBL_GCP_SERVICE_ACCOUNT_KEY=`pwd`/$SERVICE_ACCOUNT_NAME.key.json >> ~/.bashrc

echo "Done"
echo -e "Now that all pre-work is done, we will need to do a few more things:\n\nbash -l"
