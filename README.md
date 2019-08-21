# stunredis

No-configuration connections for redis-cli to Redis TLS services.

# Pre-requisites

* Install stunnel `brew install stunnel`
* Connect to VPN

## Use

To run stunredis.sh:

* Download the files.
* Get a connection string for your Redis database.
* Run `sudo ./stunredis.sh rediss://${ELASTICACHE_HOST}:${ELASTICACHE_PORT}`
* Authenticate the redis session `AUTH ${PASSWORD}`
