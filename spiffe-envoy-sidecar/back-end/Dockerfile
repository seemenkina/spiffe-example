FROM spire-agent

# Install Back-end application and configure Tomcat
RUN rm -Rf /opt/tomcat/webapps/ROOT*
COPY back-end-0.1-SNAPSHOT.war /opt/tomcat/webapps/ROOT.war
COPY server.xml /opt/tomcat/conf/server.xml

RUN mkdir /opt/back-end
COPY start-tomcat.sh /opt/back-end
RUN chmod +x /opt/back-end/start-tomcat.sh

# Create user for backend workload
RUN useradd backend -u 1000

#Copy Envoy configuration
COPY backend-envoy.yaml /opt/spiffe-helper/envoy.yaml

WORKDIR /opt/spiffe-helper

# Run the Sidecar as backend user
CMD su -c "./sidecar" backend
