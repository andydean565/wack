#!/bin/bash

git checkout main
git pull
git tag $(date -u +%Y.%m.%d) -m $(date -u +%Y.%m.%d)
git push origin --tags