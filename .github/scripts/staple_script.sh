#!/bin/bash

exit_status=65
for (( ; ; ))
do
    xcrun stapler staple -v build/macos/Build/Products/Release/Polyglot.dmg
    exit_status=$?
    if [ "${exit_status}" = "65" ]
    then
        echo "Waiting for notarization to complete"
        sleep 10
    else
        echo "Stapler status: ${exit_status}"
        break
    fi
done