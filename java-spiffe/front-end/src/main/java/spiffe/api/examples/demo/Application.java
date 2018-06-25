package spiffe.api.examples.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import spiffe.api.provider.SpiffeProvider;

@SpringBootApplication
public class Application  {

    public static void main(String[] args) throws Exception {
        SpiffeProvider.install(ACLSpiffeService.class);
        SpringApplication.run(Application.class, args);
    }
}

