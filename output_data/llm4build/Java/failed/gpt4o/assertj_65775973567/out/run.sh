#!/bin/bash

# Run tests
mvn -B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always -Drat.skip=true -Dlicense.skip=true verify