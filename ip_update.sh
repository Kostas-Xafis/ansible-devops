#!/bin/bash

# Grab my ip
PrevIP=$(cat /home/kostas/.ip)
IP=$(curl ifconfig.me -s)

if [ "${PrevIP}" = "${IP}" ]; then
    echo "IP has not changed"
    exit 0
fi

URL="http://${IP}:8080/"

# Replace 'jenkinsUrl' to current ip address
echo $URL | xargs -I @ bash -c "sudo sed -i 's&http.*<&@<&g' /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml"

# Force stop and start Jenkins
sudo service jenkins stop
sudo service jenkins start


GITHUB_TOKEN="MY_GITHUB_TOKEN"
REPO_OWNER="Kostas-Xafis"
WEBHOOK_URL="${URL}github-webhook/"
REPOS=("Dtst-2" "DtstProjectFrontend")
WEBHOOK_IDS=("485804738" "486200123")

for i in {0..1}; do
    WEBHOOK_ID=${WEBHOOK_IDS[$i]}
    REPO_NAME=${REPOS[$i]}

    # GitHub API URL to check if the webhook exists
    URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/hooks";

    #Check that the webhook exists
    response=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "${URL}/${WEBHOOK_ID}")

    # If the webhook does not exist, create it
    if [ "$response" -eq 404 ]; then

        # GitHub API URL to create a webhook
        URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/hooks"

        # Payload for the webhook
        read -r -d '' PAYLOAD << EOM
{
    "name": "web",
    "active": true,
    "events": ["push"],
    "config": {
        "url": "${WEBHOOK_URL}",
        "content_type": "json"
    }
}
EOM

        # Send the POST request to create the webhook
        response=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        -d "${PAYLOAD}" \
        "${URL}")

        # Check the response code
        if [ "$response" -eq 201 ]; then
            echo "Webhook created successfully"
        else
            echo "Failed to create webhook: ${response}"
        fi
    # If the webhook exists, update it
    else

        # GitHub API URL to update a webhook
        URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/hooks/${WEBHOOK_ID}"

        # Payload for updating the webhook
        read -r -d '' PAYLOAD << EOM
{
    "config": {
        "url": "${WEBHOOK_URL}",
        "content_type": "json"
    }
}
EOM

        # Send the PATCH request to update the webhook
        response=$(curl -s -o /dev/null -w "%{http_code}" \
        -X PATCH \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        -d "${PAYLOAD}" \
        "${URL}")

        # Check the response code
        if [ "$response" -eq 200 ]; then
            echo "Webhook updated successfully"
        else
            echo "Failed to update webhook: $response"
        fi
    fi
done

echo $IP > /home/kostas/.ip