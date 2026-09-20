#!/bin/sh
set -eu

echo "Checking proof obligations..."
bend PROOF.bend

for test_file in tests/*Test.bend; do
  echo "Running $test_file..."
  bend "$test_file"
done

echo "Bend proof and test checks passed."
