#!/bin/sh
# Env -> flag glue: the pf CLI takes flags, not env (PIRATEFACE_KEY is the one
# env it reads). Unset vars are simply omitted from the command line.
set -e
args=""
[ -n "$LANE_NAME" ] && args="$args --name $LANE_NAME"
[ -n "$MAX_SIZE" ] && args="$args --max-size $MAX_SIZE"
[ -n "$MAX_RATE" ] && args="$args --max-download-rate $MAX_RATE"
echo "pf worker starting (lane=${LANE_NAME:-unnamed} max-size=${MAX_SIZE:-any} max-rate=${MAX_RATE:-unlimited})"
exec pf work -y $args
