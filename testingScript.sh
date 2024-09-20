#!/bin/bash
make parser

TEST_DIR="tests"
for testcase in "$TEST_DIR"/*.txt; do
    testname=$(basename "$testcase" .txt)
    
    echo "Running $testname:"
    
    ./parser < "$testcase"
    echo "-----------------------------------"

done
