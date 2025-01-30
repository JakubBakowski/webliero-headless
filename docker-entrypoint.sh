#!/bin/bash

# Check if required environment variables are set
if [ -z "$WEBLIERO_TOKEN" ]; then
    echo "Error: WEBLIERO_TOKEN environment variable is not set"
    exit 1
fi

if [ -z "$ADMIN_AUTH_KEY" ]; then
    echo "Error: ADMIN_AUTH_KEY environment variable is not set"
    exit 1
fi

echo "Starting WebLiero Headless Server..."
echo "Waiting 1 second before continuing..."
sleep 1

echo "Using token: $WEBLIERO_TOKEN"
echo "Admin key configured: $ADMIN_AUTH_KEY"

# Replace admin key in basic.js
sed -i "s/ADMIN_KEY_PLACEHOLDER/$ADMIN_AUTH_KEY/" scripts/basic.js

# Start the server in the background
echo "Starting wlhl server..."
wlhl server &
SERVER_PID=$!

# Wait a bit for the server to initialize
echo "Waiting for server initialization..."
sleep 5

# Launch the room
echo "Launching WebLiero room..."
wlhl launch scripts/basic.js --id=rerev --token="$WEBLIERO_TOKEN" 2>&1 | tee /tmp/wlhl.log &
LAUNCH_PID=$!
sleep 2
if grep -q "__wbindgen_malloc" /tmp/wlhl.log; then
    echo "Error: WebAssembly binding error detected"
    echo "This usually indicates an issue with WebAssembly threading support"
    echo "Shutting down container due to WebAssembly error..."
    kill $SERVER_PID
    exit 1
fi

# Keep the container running
wait $SERVER_PID 