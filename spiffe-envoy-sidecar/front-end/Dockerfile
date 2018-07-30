FROM spire-agent

# Install Front-end application and configure Tomcat
RUN rm -Rf /opt/tomcat/webapps/ROOT*
COPY front-end-0.1-SNAPSHOT.war /opt/tomcat/webapps/ROOT.war
COPY server.xml /opt/tomcat/conf/server.xml

RUN mkdir /opt/front-end
COPY start-tomcat.sh /opt/front-end
RUN chmod +x /opt/front-end/start-tomcat.sh

#Create user for frontend workload
RUN useradd frontend -u 1000

#Copy Envoy configuration
COPY frontend-envoy.yaml /opt/spiffe-helper/envoy.yaml

WORKDIR /opt/spiffe-helper

# Run the Sidecar as frontend user
CMD su -c "./sidecar" frontend


