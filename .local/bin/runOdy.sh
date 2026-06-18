#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

cd ~/odysseus/

# 1. Create the virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv venv
fi

# 2. Activate the virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# 3. Start the Uvicorn server
echo "Starting Uvicorn server on port 7000..."
python -m uvicorn app:app --host 127.0.0.1 --port 7000
