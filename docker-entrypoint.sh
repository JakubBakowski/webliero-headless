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
sleep 2

# Launch the room
echo "Launching WebLiero room..."
wlhl launch scripts/basic.js --id=rerev --token="$WEBLIERO_TOKEN"

# Keep the container running
wait $SERVER_PID 