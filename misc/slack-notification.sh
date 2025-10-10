#!/usr/bin/env bash
set -euo pipefail

GITHUB_WORKFLOW="Test Workflow"
: "${SNS_TOPIC_ARN:?}" # The SNS Topic ARN (required)
: "${MESSAGE_DESCRIPTION:?}" # The message description (required)

: "${WORKFLOW_MESSAGE:=false}"
: "${STATUS:=}"
: "${STATUS_ICON:=}"
: "${MESSAGE_TITLE:=$( if [[ "${WORKFLOW_MESSAGE}" == "true" ]]; then echo "${GITHUB_WORKFLOW}"; fi )}"
#: "${MESSAGE_URL:=$GITHUB_WORKFLOW - $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID}"


message_payload=$(
  jq -c . << EOF
{
  "version": 1.0,
  "source": "custom",
  "content": {
    "textType": "client-markdown",
    "title": "$MESSAGE_TITLE",
    "description": "$MESSAGE_DESCRIPTION"
  },
  "metadata": {
    "enableCustomActions": false
  }
}
EOF
)
echo $message_payload
aws sns publish \
  --topic-arn "$SNS_TOPIC_ARN" \
  --message "${message_payload}"

aws sns publish \
  --topic-arn "$SNS_TOPIC_ARN" \
  --message '{
    "blocks": [
      {
        "type": "section",
        "text": {"type": "mrkdwn", "text": "*Build completed successfully!*"}
      },
      {
        "type": "context",
        "elements": [{"type": "mrkdwn", "text": "Job: `deploy-prod`"}]
      }
    ]
  }'  
