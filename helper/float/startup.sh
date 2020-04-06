#!/bin/bash
if [ -z "$LICENSE" ]; then
    echo >&2 'error: The LICENSE variable is not set.'
    "$@"
    exit 1
fi
if [ -z "$PRODUCT" ]; then
    echo >&2 'error: The PRODUCT variable is not set. Should be one of rsp, connect, rspm, ssp, rstudio'
    "$@"
    exit 1
fi

activate() {
    echo "Activating LICENSE ..."
    /usr/lib/${PRODUCT}-license-server/bin/license-server \
	-pdets=/usr/lib/${PRODUCT}-license-server/bin/license-server.dat \
	-config=/etc/${PRODUCT}-license-server.conf \
	-pidfile=/var/run/${PRODUCT}-license-server.pid \
	-a=${LICENSE}
    if [ $? -ne 0 ]
    then
        echo >&2 'error: LICENSE could not be activated.'
        exit 1
    fi     
}

deactivate() {
    echo "Deactivating license ..."
    /usr/lib/${PRODUCT}-license-server/bin/license-server -deact >/dev/null 2>&1
}

activate

# trap process exits and deactivate our license.
trap deactivate EXIT

echo "Starting server ..."
/usr/lib/${PRODUCT}-license-server/bin/license-server \
	-pdets=/usr/lib/${PRODUCT}-license-server/bin/license-server.dat \
	-config=/etc/${PRODUCT}-license-server.conf \
	-pidfile=/var/run/${PRODUCT}-license-server.pid \
	-x

#"$@"
#STATUS="$?"

