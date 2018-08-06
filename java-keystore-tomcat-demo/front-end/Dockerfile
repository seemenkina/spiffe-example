FROM spire-agent

# Install Front-end application and configure Tomcat
RUN rm -Rf /opt/tomcat/webapps/ROOT*
COPY front-end-0.1.war /opt/tomcat/webapps/ROOT.war
COPY server.xml /opt/tomcat/conf/server.xml

RUN mkdir /opt/front-end
COPY start-tomcat.sh /opt/front-end
RUN chmod +x /opt/front-end/start-tomcat.sh
COPY java.security /opt/front-end

#Create users for frontend workloads
RUN useradd frontend -u 1000
RUN useradd frontend2 -u 1001

RUN chown -R frontend /opt/tomcat
