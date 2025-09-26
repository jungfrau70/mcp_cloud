#!/bin/bash
# Neo4j healthcheck script

# Log file for debugging
LOG_FILE=/tmp/healthcheck.log
echo "Healthcheck script started at $(date)" >> $LOG_FILE

# Loop for retries
for i in {1..5}; do
    # Extract user and password from NEO4J_AUTH
    USER=$(echo "$NEO4J_AUTH" | cut -d'/' -f1)
    PASS=$(echo "$NEO4J_AUTH" | cut -d'/' -f2)

    echo "Attempt $i: Connecting with user '$USER'" >> $LOG_FILE

    # Attempt to connect
    cypher-shell -a bolt://localhost:7687 -u "$USER" -p "$PASS" 'RETURN 1' >> $LOG_FILE 2>&1
    
    # Check the exit code
    if [ $? -eq 0 ]; then
        echo "Connection successful on attempt $i" >> $LOG_FILE
        exit 0
    fi

    echo "Attempt $i failed" >> $LOG_FILE
    sleep 5
done

echo "All attempts failed. Neo4j is unhealthy." >> $LOG_FILE
exit 1