# SPIFFE Java Servlet Filter

A simple implementation of a [Java Servlet Filter](https://www.oracle.com/technetwork/java/filters-137243.html) that is
used to grant access to URLs based on the SPIFFE ID read from the X.509 Certificate that was presented by the 
client at the moment establishing the mTLS connection. 

The purpose of this example is to demonstrate a way to implement SPIFFE ID filtering on Java Applications. 

## Configuration

In the `web.xml`, specify the URLs and the SPIFFE ID that is authorized to access them: 

```
    <filter>
        <filter-name>SpiffeFilter</filter-name>
        <filter-class>spiffe.filter.SpiffeFilter</filter-class>
        <init-param>
            <param-name>accept-spiffe-id</param-name>
            <param-value>spiffe://example.org/workload</param-value>
        </init-param>
    </filter>

    <filter-mapping>
        <filter-name>SpiffeFilter1</filter-name>
        <url-pattern>/tasks/*</url-pattern>
    </filter-mapping>
```

## References

[The Essentials of Filters](https://www.oracle.com/technetwork/java/filters-137243.html)

[The Filter interface](https://tomcat.apache.org/tomcat-8.0-doc/servletapi/javax/servlet/Filter.html)
