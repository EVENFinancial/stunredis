#!/bin/bash
#
# Stunredis.sh
#
# Copyright 2018 IBM Corp.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

DATABASE_URL=$1
LOCALPORT=${2:-6479}

# This is the location of the validation chain file
lechain=./lechain.pem

# URL parsing based on https://stackoverflow.com/a/17287984
# extract the protocol
proto="`echo $DATABASE_URL | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
# remove the protocol
url=`echo $DATABASE_URL | sed -e s,$proto,,g`

hostport=`echo $url | cut -d/ -f1`
port=`echo $hostport | grep : | cut -d: -f2`
if [ -n "$port" ]; then
    host=`echo $hostport | grep : | cut -d: -f1`
else
    host=$hostport
fi

echo $hostport

# Now we create our configuration file as a variable
stunnelconf=""
stunnelconf+=$"foreground=yes\n" 
stunnelconf+=$"pid=/usr/local/var/run/stunnel.pid\n"
stunnelconf+=$"debug=7\n"
stunnelconf+=$"delay=yes\n"
stunnelconf+=$"options=NO_SSLv2\n"
stunnelconf+=$"options=NO_SSLv3\n"
stunnelconf+=$"[redis-cli]\n"
stunnelconf+=$"client=yes\n"
stunnelconf+=$"accept=127.0.0.1:$LOCALPORT\n"
stunnelconf+=$"connect=$hostport\n"

echo $stunnelconf

# We expand that out in echo and feed the result to stunnel
# which is set to take its configuration from a file descriptor
# in this case, 0, stdin.

echo -e $stunnelconf | stunnel -fd 0 &

# Sleep a moment to let the connection establish
sleep 1 
# Now call redis-cli for the user to interact with
redis-cli -p $LOCALPORT

pkill stunnel
