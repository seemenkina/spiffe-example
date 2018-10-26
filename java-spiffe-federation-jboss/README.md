# Federation and TCP support demo

This example shows a Federation scenario with two trust-domains, one having a JBOSS Wildfly Server running a web-app 
that consumes data from a PostgreSQL database proxied by a NGNIX running on the other trust-domain. 

The NGINX Proxy supports SPIFFE based TCP connections. 

The JBOSS uses the [java-spiffe](https://github.com/spiffe/java-spiffe) library that offers an interface to fetch the 
SVIDs certificates and federated bundles from the  SPIRE Workload API and provides both a Java Security Provider (KeyStore and TrustStore) and
a SocketFactory implementation that leverages that Provider for supplying the SVIDs and validating peers' SVIDs during the SSL handshake.  


### Scenario: 

![diagram-simple](Federation%20Demo%20diagram%20-%20TCP.png)

The JBOSS Server workload will get the SPIFFE ID `spiffe://example.org/front-end` and will be referred to as the _Frontend_.

The NGINX Proxy workload will get the SPIFFE ID `spiffe://test.com/back-end` and will be referred to as the _Backend_.

NGINX accepts SSL connections and connects to the local PostgresSQL database without SSL.

## Running the demo

### Requirements 

- Linux or macOS
- [Make](https://www.gnu.org/software/make)
- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Running demo automatically

To run all the steps with a command: 

```
$ make demo

Checking health...
Health Check: OK
------------------
Open in a browser: http://localhost:9000/tasks
```

If the output is _OK_, go to [http://localhost:9000/tasks](http://localhost:9000/tasks) to open the simple web-app. 

If the page displays without errors, the demo is working. 

It's recommended to run the demo step by step following the next sequence. It will help you understand 
what's going on and to troubleshoot in case there is an issue.  

### Demo step by step

Note: the outputs of the commands that show the certificates bundles and tokens are by way of example, you must use the outputs from your commands' execution.

#### Run the Docker containers: 

```
$ make run

Creating network "java-spiffe-federation-jboss_default" with the default driver
Creating spire-server-backend                    ... done
Creating spire-server-frontend                    ... done
Creating java-spiffe-federation-jboss_backend_1 ... done
Creating java-spiffe-federation-jboss_frontend_1 ... done
```

Check that the 4 docker containers are _Up_: 

```
$ docker-compose ps

java-spiffe-federation-jboss_backend_1    docker-entrypoint.sh postgres   Up      5432/tcp              
java-spiffe-federation-jboss_frontend_1   /bin/bash                       Up      0.0.0.0:9000->9000/tcp
spire-server-backend                      /bin/bash                       Up                            
spire-server-frontend                     /bin/bash                       Up  
```

#### Run the SPIRE Servers: 

##### SPIRE Server 1:
```
$ docker-compose exec spire-server-frontend ./spire-server run

DEBU[0000] Setting umask to 077                         
INFO[0000] data directory: "/opt/spire/.data"           
INFO[0000] Starting plugin catalog                       subsystem_name=catalog
DEBU[0000] KeyManager(memory): configuring plugin        subsystem_name=catalog
DEBU[0000] UpstreamCA(disk): configuring plugin          subsystem_name=catalog
DEBU[0000] DataStore(sql): configuring plugin            subsystem_name=catalog
INFO[0000] initializing database.                       
DEBU[0000] NodeAttestor(join_token): configuring plugin  subsystem_name=catalog
DEBU[0000] NodeResolver(noop): configuring plugin        subsystem_name=catalog
INFO[0000] plugins started                              
DEBU[0000] TTL: CA=24h0m0s SVID=1h0m0s                   subsystem_name=ca_manager
DEBU[0000] Manager has loaded keypair sets               subsystem_name=ca_manager
DEBU[0000] Manager is preparing keypair set "A"          subsystem_name=ca_manager
DEBU[0000] Manager is activating keypair set "A"         subsystem_name=ca_manager
DEBU[0000] Rotating server SVID                          subsystem_name=svid_rotator
DEBU[0000] Initializing API endpoints                    subsystem_name=endpoints
INFO[0000] Starting gRPC server on [::]:8081             subsystem_name=endpoints
INFO[0000] Starting UDS server /tmp/spire-registration.sock  subsystem_name=endpoints
```

##### SPIRE Server 2: 
```
$ docker-compose exec spire-server-backend ./spire-server run

DEBU[0000] Setting umask to 077                         
INFO[0000] data directory: "/opt/spire/.data"           
INFO[0000] Starting plugin catalog                       subsystem_name=catalog
DEBU[0000] NodeAttestor(join_token): configuring plugin  subsystem_name=catalog
DEBU[0000] NodeResolver(noop): configuring plugin        subsystem_name=catalog
DEBU[0000] KeyManager(memory): configuring plugin        subsystem_name=catalog
DEBU[0000] UpstreamCA(disk): configuring plugin          subsystem_name=catalog
DEBU[0000] DataStore(sql): configuring plugin            subsystem_name=catalog
INFO[0000] initializing database.                       
INFO[0000] plugins started                              
DEBU[0000] TTL: CA=24h0m0s SVID=1h0m0s                   subsystem_name=ca_manager
DEBU[0000] Manager has loaded keypair sets               subsystem_name=ca_manager
DEBU[0000] Manager is preparing keypair set "A"          subsystem_name=ca_manager
DEBU[0000] Manager is activating keypair set "A"         subsystem_name=ca_manager
DEBU[0000] Rotating server SVID                          subsystem_name=svid_rotator
DEBU[0000] Initializing API endpoints                    subsystem_name=endpoints
INFO[0000] Starting gRPC server on [::]:8081             subsystem_name=endpoints
INFO[0000] Starting UDS server /tmp/spire-registration.sock  subsystem_name=endpoints
```

#### Register Trust Domains bundles 

Show SPIRE Server 1 bundle: 

```
$ docker-compose exec spire-server-frontend ./spire-server bundle show

-----BEGIN CERTIFICATE-----
MIIBzDCCAVOgAwIBAgIJAJM4DhRH0vmuMAoGCCqGSM49BAMEMB4xCzAJBgNVBAYT
AlVTMQ8wDQYDVQQKDAZTUElGRkUwHhcNMTgwNTEzMTkzMzQ3WhcNMjMwNTEyMTkz
MzQ3WjAeMQswCQYDVQQGEwJVUzEPMA0GA1UECgwGU1BJRkZFMHYwEAYHKoZIzj0C
AQYFK4EEACIDYgAEWjB+nSGSxIYiznb84xu5WGDZj80nL7W1c3zf48Why0ma7Y7m
CBKzfQkrgDguI4j0Z+0/tDH/r8gtOtLLrIpuMwWHoe4vbVBFte1vj6Xt6WeE8lXw
cCvLs/mcmvPqVK9jo10wWzAdBgNVHQ4EFgQUh6XzV6LwNazA+GTEVOdu07o5yOgw
DwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwGQYDVR0RBBIwEIYOc3Bp
ZmZlOi8vbG9jYWwwCgYIKoZIzj0EAwQDZwAwZAIwE4Me13qMC9i6Fkx0h26y09QZ
IbuRqA9puLg9AeeAAyo5tBzRl1YL0KNEp02VKSYJAjBdeJvqjJ9wW55OGj1JQwDF
D7kWeEB6oMlwPbI/5hEY3azJi16I0uN1JSYTSWGSqWc=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIB7zCCAXSgAwIBAgIBATAKBggqhkjOPQQDAzAeMQswCQYDVQQGEwJVUzEPMA0G
A1UECgwGU1BJRkZFMB4XDTE4MTAxODE2NTcwOVoXDTE4MTAxODE3NTcxOVowHjEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBlNQSUZGRTB2MBAGByqGSM49AgEGBSuBBAAi
A2IABNU7xtLGTWFHzYFSzSHOT/+vZC1C55zC7NW1PXN/XNdGWnLdMCfKzPOCnV9G
5D8h4iSnzZYXU3oq5xh+jsl2xk6GxvAJvWPR41UafSkpcjHzzGs3NhnwnOP761LQ
t4owT6OBhTCBgjAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNV
HQ4EFgQUj/U9+Is2gG2iEkBFYxOomkQdKkgwHwYDVR0jBBgwFoAUh6XzV6LwNazA
+GTEVOdu07o5yOgwHwYDVR0RBBgwFoYUc3BpZmZlOi8vZXhhbXBsZS5vcmcwCgYI
KoZIzj0EAwMDaQAwZgIxAM1zp0yuQkwLnVQ9tQNxfCZUi/qX5n+LNNrV74tZ8Dx7
FlkduB0zMjC/Wwx3juwnrQIxAKcNb5t2i3cCSQLltS8Rn1riDVvrM5pDW+V407Y5
RHa46AptPagDT7n2OmHolBapNg==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIBkDCCARagAwIBAgIBADAKBggqhkjOPQQDAjAeMQswCQYDVQQGEwJVUzEPMA0G
A1UEChMGU1BJRkZFMB4XDTE4MTAxODE2NTcwOVoXDTE4MTAxODE3NTcxOVowADBZ
MBMGByqGSM49AgEGCCqGSM49AwEHA0IABIRrDVKWyPyB1BdC87BWePImAYyRLaxS
dZV00AR/kX4iBpWw47U+C61EyIDBxKi1uaH1/e0WnakheltBEeXrFhujYzBhMAwG
A1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAUj/U9+Is2gG2iEkBFYxOomkQdKkgwIgYD
VR0RAQH/BBgwFoYUc3BpZmZlOi8vZXhhbXBsZS5vcmcwDAYDVR0lAQH/BAIwADAK
BggqhkjOPQQDAgNoADBlAjEAgTgqAxOL1noP6nI3vpRza7skuPEXHvxZKUW5ly9s
N3Mg0OmTjFNfmhj6lkAbFDDxAjA3Hy3Lh8rqjji3vJA99C3HuGJYI6JDMWvMh1mL
xDMsRI9LM8SOAbRX2KnCndbZBYA=
-----END CERTIFICATE-----
```

The bundle shown corresponds to Trust Domain `spiffe://example.org`

Register the bundle in SPIRE Server 2: 

```
$ docker-compose exec spire-server-backend ./spire-server bundle set -id spiffe://example.org
```

Copy and paste the bundle you got in the output from the previous step, and then press Ctrl+D.


Show SPIRE Server 2 bundle: 

```
$ docker-compose exec spire-server-backend ./spire-server bundle show

-----BEGIN CERTIFICATE-----
MIIBzDCCAVOgAwIBAgIJAJM4DhRH0vmuMAoGCCqGSM49BAMEMB4xCzAJBgNVBAYT
AlVTMQ8wDQYDVQQKDAZTUElGRkUwHhcNMTgwNTEzMTkzMzQ3WhcNMjMwNTEyMTkz
MzQ3WjAeMQswCQYDVQQGEwJVUzEPMA0GA1UECgwGU1BJRkZFMHYwEAYHKoZIzj0C
AQYFK4EEACIDYgAEWjB+nSGSxIYiznb84xu5WGDZj80nL7W1c3zf48Why0ma7Y7m
CBKzfQkrgDguI4j0Z+0/tDH/r8gtOtLLrIpuMwWHoe4vbVBFte1vj6Xt6WeE8lXw
cCvLs/mcmvPqVK9jo10wWzAdBgNVHQ4EFgQUh6XzV6LwNazA+GTEVOdu07o5yOgw
DwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwGQYDVR0RBBIwEIYOc3Bp
ZmZlOi8vbG9jYWwwCgYIKoZIzj0EAwQDZwAwZAIwE4Me13qMC9i6Fkx0h26y09QZ
IbuRqA9puLg9AeeAAyo5tBzRl1YL0KNEp02VKSYJAjBdeJvqjJ9wW55OGj1JQwDF
D7kWeEB6oMlwPbI/5hEY3azJi16I0uN1JSYTSWGSqWc=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIB6jCCAXCgAwIBAgIBATAKBggqhkjOPQQDAzAeMQswCQYDVQQGEwJVUzEPMA0G
A1UECgwGU1BJRkZFMB4XDTE4MTAxODE2NTgzM1oXDTE4MTAxODE3NTg0M1owHjEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBlNQSUZGRTB2MBAGByqGSM49AgEGBSuBBAAi
A2IABAW+OS0HT1oLIcj1OF0T+XI4QYkHWdPjsXymzPD/KNx6gQMsx877BFrByWr8
J+j2n4RQIF/iZ1MSldNWKp5PO50z+57r1jaCSX1l8xRZDWnkBWOVQW2Ln6JB+FdE
YkzKwaOBgTB/MA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
DgQWBBT06RHPxJorFBWtvmqLdOvosgcCYzAfBgNVHSMEGDAWgBSHpfNXovA1rMD4
ZMRU527TujnI6DAcBgNVHREEFTAThhFzcGlmZmU6Ly90ZXN0LmNvbTAKBggqhkjO
PQQDAwNoADBlAjAh/IlmTjOI0PWuXJYM6hElvwNXJPz3+tRzufdRmT9U1NEC0OVg
Qmor+STonVLhLHYCMQDSdMTbcjrigp5lV2/Sx3yMOLTZt9J2bSZpUiof3XOP/itL
TqjOr6dz2cheyp2asv4=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIBjTCCAROgAwIBAgIBADAKBggqhkjOPQQDAjAeMQswCQYDVQQGEwJVUzEPMA0G
A1UEChMGU1BJRkZFMB4XDTE4MTAxODE2NTgzM1oXDTE4MTAxODE3NTg0M1owADBZ
MBMGByqGSM49AgEGCCqGSM49AwEHA0IABCrkDJe/awX2kchzgI/CwgAmTlMfAtCH
fN89kU/rnbU6NGmHeXnYepMsUHA5YCA3CtPZsNPD+m3Q5I13srIOQZ+jYDBeMAwG
A1UdEwEB/wQCMAAwHwYDVR0jBBgwFoAU9OkRz8SaKxQVrb5qi3Tr6LIHAmMwHwYD
VR0RAQH/BBUwE4YRc3BpZmZlOi8vdGVzdC5jb20wDAYDVR0lAQH/BAIwADAKBggq
hkjOPQQDAgNoADBlAjBXL2iFYDf59bvysJCJaYLzdl19QQWrAIjOmCcyCGWtVcU0
50o4IQtFeVZNjdBcPg0CMQC+SzMNa2Yr6TcAiiPVNNxeWO62yxZ5KD5FGTBXNs0K
4tHYsCGGX98GE0TKyh2Spag=
-----END CERTIFICATE-----
```

The bundle shown corresponds to Trust Domain `spiffe://test.com`

Register the bundle in SPIRE Server 1: 

```
$ docker-compose exec spire-server-frontend ./spire-server bundle set -id spiffe://test.com
```

Copy and paste the bundle you got in the output from the previous step, and then press Ctrl+D.


#### Generate the entries in the SPIRE Server registries: 

Register SPIFFE ID `spiffe://example.org/front-end`:

```
$ docker-compose exec spire-server-frontend ./spire-server entry create -parentID spiffe://example.org/host -spiffeID spiffe://example.org/front-end -federatesWith spiffe://test.com -selector unix:uid:1000

Entry ID:	2a162e5f-7ee7-4ee2-8c89-0d290b0d9dce
SPIFFE ID:	spiffe://example.org/front-end
Parent ID:	spiffe://example.org/host
TTL:		3600
Selector:	unix:uid:1000
FederatesWith:	spiffe://test.com
```

An Entry was created in SPIRE Server 1 Registry for the spiffe id `spiffe://example.org/front-end` that federates with the Trust Domain `spiffe://test.com`


Register SPIFFE ID `spiffe://test.com/front-end`:

```
$ docker-compose exec spire-server-backend ./spire-server entry create -parentID spiffe://test.com/host -spiffeID spiffe://test.com/back-end -federatesWith spiffe://example.org -selector unix:uid:1000

Entry ID:	ced66654-fe63-46e5-895b-3896b686ea6a
SPIFFE ID:	spiffe://test.com/back-end
Parent ID:	spiffe://test.com/host
TTL:		3600
Selector:	unix:uid:1000
FederatesWith:	spiffe://example.org
```

An Entry was created in SPIRE Server 2 Registry for the spiffe id `spiffe://test.com/back-end` that federates with the Trust Domain `spiffe://example.org`

#### Register the SPIRE Agents

Generate Token for SPIRE Agent 1: 

```
$ docker-compose exec spire-server-frontend ./spire-server token generate -spiffeID spiffe://example.org/host

Token: ac37c7b9-3eee-435a-adac-fb6822ad325c
```

Copy the token you got in the output and run the following command replacing the token: 

```
$ docker-compose exec frontend ./spire-agent run -joinToken ac37c7b9-3eee-435a-adac-fb6822ad325c

INFO[0000] Starting plugin catalog                       subsystem_name=catalog
DEBU[0000] KeyManager(memory): configuring plugin        subsystem_name=catalog
DEBU[0000] WorkloadAttestor(k8s): configuring plugin     subsystem_name=catalog
DEBU[0000] WorkloadAttestor(unix): configuring plugin    subsystem_name=catalog
DEBU[0000] NodeAttestor(join_token): configuring plugin  subsystem_name=catalog
DEBU[0000] No pre-existing agent SVID found. Will perform node attestation  subsystem_name=attestor
DEBU[0000] Requesting SVID for spiffe://example.org/front-end  subsystem_name=manager
DEBU[0000] Requesting SVID for spiffe://example.org/host  subsystem_name=manager
INFO[0000] Starting workload API                         subsystem_name=endpoints
```

SPIRE Agent 1 is running. 


Generate Token for SPIRE Agent 2: 

```
$ docker-compose exec spire-server-backend ./spire-server token generate -spiffeID spiffe://test.com/host

Token: ac37c7b9-3eee-435a-adac-fb6822ad325c
```

Copy the token you got in the output and run the following command replacing the token: 

```
$ docker-compose exec backend ./spire-agent run -joinToken b41fb422-8294-48a1-8758-b38682b82446

INFO[0000] Starting plugin catalog                       subsystem_name=catalog
DEBU[0000] NodeAttestor(join_token): configuring plugin  subsystem_name=catalog
DEBU[0000] KeyManager(memory): configuring plugin        subsystem_name=catalog
DEBU[0000] WorkloadAttestor(k8s): configuring plugin     subsystem_name=catalog
DEBU[0000] WorkloadAttestor(unix): configuring plugin    subsystem_name=catalog
DEBU[0000] No pre-existing agent SVID found. Will perform node attestation  subsystem_name=attestor
DEBU[0000] Requesting SVID for spiffe://test.com/back-end  subsystem_name=manager
DEBU[0000] Requesting SVID for spiffe://test.com/host    subsystem_name=manager
INFO[0000] Starting workload API                   
```


#### Run the NGINX Proxy: 

```
$ docker-compose exec backend /opt/nginx/nginx

2018/10/18 17:29:38 [notice] 39#0: using the "epoll" event method
2018/10/18 17:29:38 [notice] 39#0: nginx/1.13.9
2018/10/18 17:29:38 [notice] 39#0: built by gcc 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.10) 
2018/10/18 17:29:38 [notice] 39#0: OS: Linux 4.15.0-36-generic
2018/10/18 17:29:38 [notice] 39#0: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2018/10/18 17:29:38 [notice] 39#0: start worker processes
2018/10/18 17:29:38 [notice] 39#0: start worker process 46
2018/10/18 17:29:38 [notice] 39#0: signal 28 (SIGWINCH) received
2018/10/18 17:29:38 [notice] 46#0: signal 28 (SIGWINCH) received
2018/10/18 17:29:38 [info] 46#0: epoll_wait() failed (4: Interrupted system call)
```

#### Run the JBOSS Wildfly Server: 

```
$ docker-compose exec frontend /opt/front-end/start-jboss.sh

17:30:35,065 INFO  [org.jboss.as.server] (ServerService Thread Pool -- 42) WFLYSRV0010: Deployed "ROOT.war" (runtime-name : "ROOT.war")
17:30:35,109 INFO  [org.jboss.as.server] (Controller Boot Thread) WFLYSRV0212: Resuming server
17:30:35,111 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0060: Http management interface listening on http://0.0.0.0:9990/management
17:30:35,111 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0051: Admin console listening on http://0.0.0.0:9990
17:30:35,111 INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0025: WildFly Full 14.0.1.Final (WildFly Core 6.0.2.Final) started in 8934ms - Started 522 of 707 services (326 services are lazy, passive or on-demand)
```

Try open in browser [http://localhost:9000/tasks](http://localhost:9000/tasks)

If the page displays without errors, the demo is running correctly.

#### Clean the environment: 

```
$ make clean 
```

## Configurations in detail

### Frontend

In the Frontend there is a JBOSS Widlfly Server running a simple Spring Boot webapp that consumes data from a Database and
generates an HTML with that data. 

The connection to the PostgreSQL database is configured through a DataSource defined in `/opt/jboss/standalone/configuration/standalone.xml`: 

```
<datasource jndi-name="java:jboss/datasources/TasksDS" pool-name="TasksDS" enabled="true" use-java-context="true" >
    <connection-property name="url">
        jdbc:postgresql://backend:8443/tasks_service?socketFactory=spiffe.provider.SpiffeSocketFactory
    </connection-property>
    <driver>postgresql</driver>
    <pool>
        <min-pool-size>1</min-pool-size>
    </pool>
    <security>
        <user-name>postgres</user-name>
        <password>postgres</password>
    </security>
    <validation>
        <check-valid-connection-sql>select 1</check-valid-connection-sql>
    </validation>
</datasource>
``` 

`backend:8443` is where the NGINX is listening for SSL connections. 
The URL has a parameter `socketFactory` that configures the SocketFactory implementation to be used to create the Socket. 
The `SPIFFESocketFactory` from the [java-spiffe](https://github.com/spiffe/java-spiffe) will be used to create the Socket
to connect to the NGINX proxy. 

The reason for using the parameter `socketFactory` and not the parameter `sslfactory` is that the connection to the PostgreSQL is 
not on SSL, the connection between the JBOSS Server and the NGINX is on SSL, and then the NGINX redirects the traffic to 
the local Database without using SSL. For establishing the connection between the JBOSS and the NGINX is required a custom SocketFactory
that leverages the SPIFFE KeyStore that handles the SVIDs fetched from the SPIRE Workload API. During that handshake both peers validate 
each other using the peers SVIDs and the federated bundles they got from the Workload API. 

### Backend

In the Backend there is a NGINX Proxy that accepts TCP connections using SSL. The config file looks as follows:

```
daemon off;

# Unix user that has an entry in the registry
user backend;

pid nginx.pid;
worker_processes 1;
error_log /dev/stdout info;
events {
  worker_connections 1024;
}

stream {
  server {
    listen       8443 ssl;

    # Fetch SVIDs
    # Socket path of SPIRE Agent
    ssl_spiffe_sock       /tmp/agent.sock;

    # Required to enable ssl
    ssl_verify_client on;

    # Enable or disable SPIFFE ID validation of clients in HTTPS servers
    ssl_spiffe on;

    # List of SPIFFE IDs to accept from client's certificate
    ssl_spiffe_accept spiffe://example.org/front-end;

    # Redirect traffic to postgres database
    proxy_pass            localhost:5432;
  }
}
```

It validates that the SPIFFE ID in the Peer's SVID is `spiffe://example.org/front-end`.

## More information

[java-spiffe library](https://github.com/spiffe/java-spiffe/blob/master/README.md)

[PostgreSQL JDBC Driver](https://jdbc.postgresql.org/documentation/94/connect.html)



