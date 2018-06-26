# Securing Java microservices with SPIFFE

This example shows two java applications running in Spring Boot embedded Tomcats interacting over mTLS using SVID-X509
certificates that are fetched and updated automatically from the SPIRE Agent using the [java-spiffe](https://github.com/spiffe/java-spiffe) library.

A SPIFFE Java Security Provider has been implemented to handle the SVID with the Private Key and Trust Chain in memory
and to validate the trust chain and SPIFFE ID presented by the other peer. 

The current example consists of the following modules:

_**back-end**_: simple Spring boot application with a RestController that handles GET requests over mTLS. 

_**front-end**_: simple Spring boot application that connects over mTLS with the back-end.
It accepts insecure connection over http on port _4001_ to show an html.

_**spiffe-security-provider**_: the implementation of a java security provider that handles and validates SPIFFE X509-SVIDs 
certificates obtained from a SPIRE Agent. Used for the certificate validation during the handshake for 
establishing mTLS connections with trusted workloads. It implements a KeyStore, KeyManager and TrustManager to handle the certificates in 
memory. Uses the [java-spiffe](https://github.com/spiffe/java-spiffe) library to fetch the X509-SVIDs.

_**[java-spiffe](https://github.com/spiffe/java-spiffe)**_: library for interacting over gRPC with a SPIFFE Workload API, that allows to register a listener
so the the SPIFFE Agent pushes the SVIDs to the listener every time there are new ones issued. It implements exponential backoff retries in case of errors interacting with the 
Workload API.

_**acl-manager**_: implementation of a simple manager for handling a list of trusted SPIFFE IDs. 

## Demo scenario 

### Components

This demo is composed of 3 containers: two workloads with their respective SPIRE agents and one SPIRE server.

![spiffe-java diagram](spiffe-java-diagram.png)

#### Registration Entries

| Workload        | Selector      | SPIFFE ID                           | Parent ID                  |
| --------------- | --------------|-------------------------------------| ---------------------------|
| Java Back-end   | unix:uid:1000 | spiffe://example.org/back-end       | spiffe://example.org/host1 |
| Java Front-end  | unix:uid:1000 | spiffe://example.org/front-end      | spiffe://example.org/host2 | 

### Run the demo

##### Prerequisites

- MacOS or Linux 
- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Screen](https://www.gnu.org/software/screen)

##### 1. Clone this Repo

##### 2. Build and Run the docker containers

```
$ make demo
```

##### 3. Connect a multiplex console to the containers:

```
$ cd harness
$ make screen
```

##### 4. Run the SPIRE Server 

On the spire-server console on the left:
```
$ ./spire-server run & 
```

##### 5. Generate Tokens

###### 5.1 Generate Agent Token for Back-end and Run the Agent

On the spire-server console on the right:
```
$ ./spire-server token generate -spiffeID spiffe://example.org/host1
```

Copy the Token.
On the _spire-agent-1_ console:

```
$ ./spire-agent run -joinToken {token}
```

Replace `{token}` by the generated token.

###### 5.2 Generate Agent Token for Front-end and Run the Agent

On the spire-server console:
```
$ ./spire-server token generate -spiffeID spiffe://example.org/host2
```

Copy the Token.
On the _spire-agent-2_ console:

```
$ ./spire-agent run -joinToken {token}
```
Replace `{token}` by the generated token.

##### 6. Create entries on spire server for the workloads

On the spire-server console run:
```
$ ./spire-server entry create -parentID spiffe://example.org/host1 -spiffeID spiffe://example.org/back-end -selector unix:uid:1000 -ttl 120
$ ./spire-server entry create -parentID spiffe://example.org/host2 -spiffeID spiffe://example.org/front-end -selector unix:uid:1000 -ttl 120
```

This entries are configured with a TTL of 120s to show the rotation of certificates and how it continues working when the 
certificates are pushed from the SPIRE Agent to the workloads.

##### 7. Run the apps
 
##### 7.1 Run the Back-end 

On the _back-end_ console run:

```
$ ./run-backend.sh
```

Check on the console that the correct SPIFFE ID has been received:

```
INFO    spiffe.api.provider.SpiffeSVIDManager: SPIFFE ID fetched: spiffe://example.org/back-end
```

##### 7.2 Run the Front-end 

On the _front-end_ console run:

```
$ ./run-frontend.sh
```

Check on the console that the correct SPIFFE ID has been received:

```
INFO    spiffe.api.provider.SpiffeSVIDManager: SPIFFE ID fetched: spiffe://example.org/front-end
```

##### 8. Open Web App

Open a browser an go to [http://localhost:4001/tasks](http://localhost:4001/tasks)

The page should be displayed without errors. 

On the _back-end_ console you should see this line:

```
INFO  s.api.provider.SpiffeTrustManager - Checking SPIFFE ID spiffe://example.org/front-end
```

On the _front-end_ console you should see this line:

```
INFO  s.api.provider.SPIFFETrustManager - Checking SPIFFE ID spiffe://example.org/back-end
```

##### 9. Run the Front-end with another identity

Registry another workload

On the spire-server console run:
```
$ ./spire-server entry create -parentID spiffe://example.org/host2 -spiffeID spiffe://example.org/front-end2 -selector unix:uid:1001 -ttl 120
```

On the Front-end console, stop the app and run:

```
$ ./run-frontend.sh frontend2
```

Check on the console that the correct SPIFFE ID has been received:

```
INFO    spiffe.api.provider.SpiffeSVIDManager: SPIFFE ID fetched: spiffe://example.org/front-end2
```

As this SPIFFE ID is not trusted by the Backend, the web page will show an error. 

Now if you want the server to trust the new SPIFFE ID, go the _back-end_ console and edit the file `spiffe-id_whitelist-back` that is in `/opt/back-end`. 

Add a line with `spiffe://example.org/front-end2`

Try again on the browser. Now the page should display correctly. 
