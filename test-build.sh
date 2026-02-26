#!/bin/bash

export LC_CTYPE=C; export LANG=C;

# Initialize counters
FAST_COUNT=0
SLOW_COUNT=0

for i in {1..1000}; do
  # Mark the start time using the shell's internal timer
  START_TIME=$SECONDS

  export RANDOM_TAG=$(tr -dc 'a-z' < /dev/urandom | head -c 8);

  echo "--- Iteration $i: Starting build ($RANDOM_TAG) ---"

  # gtimeout will send a SIGTERM after 10s.
  # If the process doesn't stop, it returns exit code 124.
  CRT_DIR="$HOME/workspace/projects/huma/craft-cloud/cli/internal/adapters/container/buildkitcerts"
  CACERT="$CRT_DIR/ca.pem"
  TLSCERT="$CRT_DIR/cert.pem"
  TLSKEY="$CRT_DIR/key.pem"
  BUILDKIT_CERT_ARGS="--tlscacert $CACERT --tlscert $TLSCERT --tlskey $TLSKEY"
  BUILDKIT_HOST="tcp://craft-cloud-buildkit.sbx.huma.com:24317"
  # BUILDKIT_HOST="tcp://craft-cloud-buildkit-staging:1234"
  # BUILDKIT_CERT_ARGS=""
  # BUILDKIT_FLAGS="--progress=plain"
  # DEBUG_FLAGS="--debug"
  # COMMAND="buildctl $DEBUG_FLAGS --addr $BUILDKIT_HOST $BUILDKIT_CERT_ARGS build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=europe-west2-docker.pkg.dev/hu-staging-1/hcc-stgn-1-3-4/fastapi-example:$RANDOM_TAG,push=true $BUILDKIT_FLAGS"
  COMMAND="craft-cli build --push --tag $RANDOM_TAG --verbose"
  gtimeout 20s $COMMAND
  # $COMMAND
  EXIT_STATUS=$?

  # Calculate how long that specific command actually took
  DURATION=$(( SECONDS - START_TIME ))
  RESULT_MSG="SUCCESS - Finished in ${DURATION}s"

  # Check if gtimeout triggered (Exit code 124)
  if [ $EXIT_STATUS -eq 124 ]; then
    ((SLOW_COUNT++))
    RESULT_MSG="TIMEOUT (>30s) - Command Terminated"
  else
    ((FAST_COUNT++))
    RESULT_MSG="SUCCESS - Finished in ${DURATION}s"
  fi

  # Print iteration summary
  echo "Iteration $i Result: $RESULT_MSG"
  echo "Cumulative -> Fast: $FAST_COUNT | Slow: $SLOW_COUNT"
  echo "-----------------------------------------------"

  # Wait 2 seconds before the next loop as per your original script
  sleep 2;
done

# in case of buildkit, with local docker config json
# Cumulative -> Fast: 156 | Slow: 10

# in case of buildkit, with local docker config json
# Cumulative -> Fast: 95 | Slow: 8