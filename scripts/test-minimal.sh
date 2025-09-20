#!/bin/bash

echo "Test 1: Basic echo"

# Test logging function
log() {
    echo "$1" | tee -a "../meta/validation-log.txt"
}

echo "Test 2: About to test log function"
log "Test log message"
echo "Test 3: Log function worked"

# Test the basic structure
validate_success() {
    echo "✅ $1"
}

echo "Test 4: About to call validate_success"
validate_success "Test validation"
echo "Test 5: All tests complete"
