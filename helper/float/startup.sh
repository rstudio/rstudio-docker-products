#!/bin/bash
if [ -z "$LICENSE" ]; then
    echo >&2 'error: The LICENSE variable is not set.'
    "$@"
    exit 1
fi

# NOTE: the PRODUCT is replaced / substituted at build time by sed
# (i.e. verbatim text replacement)

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
    echo "Stopping server"
    PID=$(cat /var/run/${PRODUCT}-license-server.pid)
    kill -9 $PID
    wait $PID
    echo "Deactivating license ..."
    /usr/lib/${PRODUCT}-license-server/bin/license-server \
	-pdets=/usr/lib/${PRODUCT}-license-server/bin/license-server.dat \
	-config=/etc/${PRODUCT}-license-server.conf \
	-deact
    echo "Done"
}

activate

# trap process exits and deactivate our license.
trap deactivate EXIT

echo "Starting server ..."
# background so that stdout / stderr continue going to the parent shell
/usr/lib/${PRODUCT}-license-server/bin/license-server \
	-pdets=/usr/lib/${PRODUCT}-license-server/bin/license-server.dat \
	-config=/etc/${PRODUCT}-license-server.conf \
	-pidfile=/var/run/${PRODUCT}-license-server.pid \
	-x &

SERVER_PID=$!
echo "Waiting for PID: $SERVER_PID"
wait $SERVER_PID

#"$@"
#STATUS="$?"

