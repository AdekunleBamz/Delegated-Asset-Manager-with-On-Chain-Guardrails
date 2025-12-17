#!/bin/bash
set -e

git checkout -b fix/delete-simnet

rm settings/Simnet.toml

git add settings/Simnet.toml
git commit -m "Delete Simnet.toml"
git checkout main
git merge fix/delete-simnet

echo "Deleted Simnet.toml"
