package spiffe.api.examples.demo;

import org.apache.catalina.connector.Connector;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TomcatConfiguration {

    @Value("${server.http.port}")
    private int port;

    @Bean
    public WebServerFactoryCustomizer containerFactoryCustomizer() {
        return factory -> {
            TomcatServletWebServerFactory tomcatServletWebServerFactory = (TomcatServletWebServerFactory) factory;
            Connector connector = new Connector();
            connector.setPort(port);
            connector.setScheme("http");
            tomcatServletWebServerFactory.addAdditionalTomcatConnectors(connector);
        };
    }
}
