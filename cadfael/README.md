# AWS EC2 instance Attestation and Envoy Demo

This demo shows two workloads, running on separate AWS instances and estabishing mTLS connection over Envoy Proxy using SVIDs.

Workload Blog is a simple bulletin board application(flaskBB) and workload Database is a mariadb database. Workloads are attested using kernel based attestation, wherein the workload process is interogated for the pre-registered uid.

AWS instances are attested through aws Instance Identity Document(IID), SPIRE Agent running on the instance presents its IID to the SPIRE Server for verification. More details about setting up AWS attestation using aws-iid-attestor plugin is [here](https://github.com/spiffe/aws-iid-attestor/blob/master/README.md)

The SPIFFE sidecar process is responsible for starting and managing the envoy proxy. It fetches certificates from the Workload API, writes them to the filesystem and signals envoy to hot restart when new certificates are available.


![Cadfael Diagram](envoy_cadfael.png)

## Creating the demo

Prerequisites:
* GNU screen >=4.06 on the host machine (optional, for split-screen demo)

 `make up` creates the demo setup on aws EC2 instances:

1. [Setup basic VPC and EC2 setup on AWS](../ec2/README.md)
1. Launch SPIRE Server as systemd service on the server EC2 instance.
1. Launch SPIRE Agent as systemd service on the Blog and Database EC2 instances.
1. Setup SPIFFE Sidecar on both Blog and Database EC2 instances.
1. Setup Envoy Proxy for Blog and Database EC2 instances.
1. Setup flaskBB on Blog EC2 instance.
1. Setup and start mariadb on Database EC2 instance.

## Running the demo

`make harness` creates screen session with 6 panes, 2 panes for each of SPIRE Server, Blog and Database ec2 instances.

Follow steps to run the demo:
1. Register the Blog and Database workloads, in the top right SPIRE Server pane run the following command:

        /opt/spire/spire-server register \
            -parentID spiffe://example.org/spire/agent/aws_iid_attestor/<aws_account_id>/<database_ec2_instance_id> \
            -spiffeID spiffe://example.org/Database \
            -selector unix:uid:1000


        /opt/spire/spire-server register \
            -parentID spiffe://example.org/spire/agent/aws_iid_attestor/<aws_account_id>/<blog_ec2_instance_id> \
            -spiffeID spiffe://example.org/Blog \
            -selector unix:uid:1000

1. Launch SPIFFE Sidecar on Blog and Database ec2 instances as background process, run the following commands in the right middle and bottom panes:

        cd /opt/sidecar/bin
        ./sidecar &

1. Launch flaskBB workload on the Blog ec2 instance as a backgroud process, run the following command in one of the middle panes:

        cd /home/ubuntu/flaskbb
        flaskbb --config flaskbb.cfg run --host 0.0.0.0 --port 8080 &

1. Outside of the screen panes from `spiffe-example/cadfael` directory run `make env` to get the Blog ec2 instance's Public IP

1. Point your browser to <Blog_ec2_instance_Public_IP>:8080 to access the flaskBB application

1. Examine conifigurations [Envoy Database](remote/database_envoy.json), [envoy Blog](remote/blog_envoy.json) and [FlaskBB](remote/flaskbb.cfg):

   FlaskBB database config is set to envoy proxy listener port `8003`

        SQLALCHEMY_DATABASE_URI = "mysql://dbuser:badpass@0.0.0.0:8003/forum_db"

   Envoy proxy on the Blog side listens on port `8003` and use the ssl_context below to establish mTLS with Database:

         "ssl_context": {
           "cert_chain_file": "/certs/svid.pem",
           "private_key_file": "/certs/svid_key.pem",
           "ca_cert_file": "/certs/svid_bundle.pem",
           "ecdh_curves": "X25519:P-256:P-521:P-384",
           "verify_subject_alt_name": [
             "spiffe://example.org/Database"
           ]}


    Envoy proxy on the Database side is set to listen on port `8002`, use the ssl_context to establish mTLS with Blog:

        "ssl_context": {
          "cert_chain_file": "/certs/svid.pem",
          "private_key_file": "/certs/svid_key.pem",
          "ca_cert_file": "/certs/svid_bundle.pem",
          "ecdh_curves": "X25519:P-256:P-521:P-384",
          "verify_subject_alt_name": [
            "spiffe://example.org/Blog"
          ]}

## Cleaning up the demo setup
`make destroy` will delete all the ec2 demo setup.