FROM spire-agent

# Install Back-end application and configure Tomcat
RUN rm -Rf /opt/tomcat/webapps/ROOT*
COPY back-end-0.1.war /opt/tomcat/webapps/ROOT.war
COPY server.xml /opt/tomcat/conf/server.xml

RUN mkdir /opt/back-end
COPY start-tomcat.sh /opt/back-end
RUN chmod +x /opt/back-end/start-tomcat.sh

COPY java.security /opt/back-end

# Create user for backend workload
RUN useradd backend -u 1000
RUN chown -R backend /opt/tomcat
