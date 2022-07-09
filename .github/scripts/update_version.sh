#!/bin/bash
set -e

git config --global user.email "utvikler@progit.no"
git config --global user.name "Progit Utvikler"

# Find and increment the version number.
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml

# Commit and tag this change.
version=$(grep 'version: ' pubspec.yaml | sed 's/version: //')
git commit -m "Create tag $version" pubspec.yaml
git tag "v$version"
git push --atomic origin dev "v$version"