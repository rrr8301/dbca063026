#!/bin/bash
set -e
mvn install -e -B -V -Prun-its,mimir -Drat.skip=true -Dlicense.skip=true