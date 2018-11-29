
How to generate a new certificate:

1. Generate two CA certificates.

The first one is based on the following information:
```
CN: RootCA; 
Country: US; 
Organization: test1.example.org
```

The second one uses the following:
```
CN: RootCA; 
Country: US; 
Organization: test3.example.org
```

Run:
```
$ openssl genrsa -out ca-key.pem 4096
$ openssl req -x509 -new -sha256 -key ca-key.pem -days 3650 -out ca-crt.pem
```

2. Generate two Intermediate CA CSRs and sign them by relevant CA.

Certificate information for the first certificate is as follows:
```
CN: IntermediateCA; 
Country: US; 
Organization: test1.example.org
```

Certificate information for the second certificate is as follows:
```
CN: IntermediateCA; 
Country: US; 
Organization: test3.example.org
```

Run:
```
$ openssl genrsa -out ca2-key.pem 4096
$ openssl req -new -sha256 -key ca2-key.pem -out ca2-csr.pem
$ openssl x509 -req -in ca2-csr.pem -CA ca-crt.pem -CAkey ca-key.pem -CAcreateserial -out ca2-crt.pem -days 3650
```

3. Generate a signed database certificate and a signed blog certificate.

```
CN: database; 
Country: US; 
Organization: test1.example.org
```
$ openssl genrsa -out server-key.pem 4096
$ openssl req -new -sha256 -key server-key.pem -out server-csr.pem -config openssl.cnf
$ openssl x509 -req -in server-csr.pem -CA ca2-crt.pem -CAkey ca2-key.pem -CAcreateserial -out database-crt.pem -days 3650 -extfile v3.ext

Certificate information for the blog cert:
```
CN: blog; 
Country: US; 
Organization: test3.example.org
```
$ openssl genrsa -out client-key.pem 4096
$ openssl req -new -sha256 -key client-key.pem -out client-csr.pem -config openssl.cnf
$ openssl x509 -req -in client-csr.pem -CA ca2-crt.pem -CAkey ca2-key.pem -CAcreateserial -out blog-crt.pem -days 3650 -extfile v3.ext

Use this configuration files for database:

v3.ext:
    ```
    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = database
    URI.1 = spiffe://dev.example.org/path/service
    ```
	
openssl.cnf:
    ```
    [ req ]
    #default_bits		= 2048
    #default_md		= sha256
    #default_keyfile 	= privkey.pem
    distinguished_name	= req_distinguished_name
    attributes		= req_attributes
    req_extensions = v3_req

    [ req_distinguished_name ]
    countryName			= Country Name (2 letter code)
    countryName_min			= 2
    countryName_max			= 2
    stateOrProvinceName		= State or Province Name (full name)
    localityName			= Locality Name (eg, city)
    0.organizationName		= Organization Name (eg, company)
    organizationalUnitName		= Organizational Unit Name (eg, section)
    commonName			= Common Name (eg, fully qualified host name)
    commonName_max			= 64
    emailAddress			= Email Address
    emailAddress_max		= 64

    [ req_attributes ]
    challengePassword		= A challenge password
    challengePassword_min		= 4
    challengePassword_max		= 20

    [ v3_req ]
    subjectAltName = @alt_names
    [alt_names]
    DNS = database
    URI = spiffe://dev.example.org/path/service
    ```

Use this configuration file for the blog:

v3.ext:
    ```
    authorityKeyIdentifier=keyid,issuer
    basicConstraints=CA:FALSE
    keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = blog
    URI.1 = spiffe://blog.dev.example.org/path/service
    ```

openssl.cnf:
    ```
    [ req ]
    #default_bits		= 2048
    #default_md		= sha256
    #default_keyfile 	= privkey.pem
    distinguished_name	= req_distinguished_name
    attributes		= req_attributes
    req_extensions = v3_req

    [ req_distinguished_name ]
    countryName			= Country Name (2 letter code)
    countryName_min			= 2
    countryName_max			= 2
    stateOrProvinceName		= State or Province Name (full name)
    localityName			= Locality Name (eg, city)
    0.organizationName		= Organization Name (eg, company)
    organizationalUnitName		= Organizational Unit Name (eg, section)
    commonName			= Common Name (eg, fully qualified host name)
    commonName_max			= 64
    emailAddress			= Email Address
    emailAddress_max		= 64

    [ req_attributes ]
    challengePassword		= A challenge password
    challengePassword_min		= 4
    challengePassword_max		= 20

    [ v3_req ]
    subjectAltName = @alt_names
    [alt_names]
    DNS = blog
    URI = spiffe://blog.dev.example.org/path/service
    ```

4. Create main key file for the database and the blog:
Blog:
- `ca-chain.cert.pem` consists of certificate from `ca2-crt.pem` and certificate from `ca-crt.pem`. Use certificate where `Organization: test1.example.org`
- `client.key.pem` consists of certificate from `blog-crt.pem` and private key from `client-key.pem`

Database:
- `ca-chain.cert.pem` consists of certificate from `ca2-crt.pem` and certificate from `ca-crt.pem`. Use certificate where `Organization: test3.example.org`
- `server.key.pem` consists of certificate from `database-crt.pem` and private key from `server-key.pem`
