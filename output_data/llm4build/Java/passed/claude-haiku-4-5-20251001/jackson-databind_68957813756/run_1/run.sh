#!/bin/bash
set -e
mvn -B -ff -ntp verify -Drat.skip=true -Dlicense.skip=true