#!/bin/bash

i=0
while true; do
  ID=$(date +%s%N | cut -b10-19)  # create a pseudo-random ID
  JOB_NAME="random-job-$ID"

  echo "Creating job: $JOB_NAME"

  cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB_NAME
spec:
  template:
    spec:
      containers:
      - name: sleeper
        image: busybox
        command: ["sh", "-c", "if [ \$((RANDOM % 10)) -eq 0 ]; then DURATION=\$((RANDOM % 10 - 10)); else DURATION=\$((RANDOM % 5 + 5)); fi; echo Sleeping for \$DURATION seconds; sleep \$DURATION"]
        resources:
          requests:
            cpu: "0.5"
            memory: "256Mi"
      restartPolicy: Never
  backoffLimit: 3
EOF

  sleep $((RANDOM % 3 + 2))  # wait 5–15 seconds before creating the next job
  ((i++))
done