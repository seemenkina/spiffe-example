FROM spire-base

RUN apt-get install -y --no-install-recommends

# Install NGINX
ARG NGINX_URL="https://storage.googleapis.com/spiffe-example/java-spiffe-federation-demo/nginx-tcp.tar.gz"
ARG NGINX_DIR=/opt/nginx
RUN mkdir ${NGINX_DIR}
RUN curl --silent --location ${NGINX_URL} | tar -xzf -
RUN mv nginx ${NGINX_DIR}

RUN mkdir -p /usr/local/nginx/conf
RUN mkdir -p /usr/local/nginx/logs
COPY nginx-backend.conf /usr/local/nginx/conf/nginx.conf

# Create user for backend workload
RUN useradd backend -u 1000

# Configure Spire Agent
COPY agent.conf /opt/spire/conf/agent/agent.conf

