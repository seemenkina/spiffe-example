package spiffe.api.provider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.net.ssl.SSLEngine;
import javax.net.ssl.X509ExtendedTrustManager;
import java.net.Socket;
import java.security.Security;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Optional;

import static java.lang.String.format;
import static spiffe.api.provider.CertificateUtils.getSpiffeId;

/**
 * This class implements the Trust and SpiffeID validation
 *
 */
public class SpiffeTrustManager extends X509ExtendedTrustManager  {

    private final SpiffeSVIDManager spiffeSVIDManager;
    private ACLService aclService;

    SpiffeTrustManager() {
        spiffeSVIDManager = SpiffeSVIDManager.getInstance();
        String aclServiceClass = Security.getProperty(SpiffeProviderConstants.ACL_SERVICE_PROPERTY);
        aclService = ReflectionUtils.instantiate(aclServiceClass);
    }

    /**
     * Given the partial or complete certificate chain provided by the peer,
     * build a certificate path to a trusted root and return if it can be validated
     * and is trusted for client SSL authentication based on the authentication type.
     *
     * @param chain the peer certificate chain
     * @param authType the authentication type based on the client certificate
     * @throws CertificateException
     */
    @Override
    public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        checkPeer(chain);
    }

    /**
     * Given the partial or complete certificate chain provided by the peer,
     * build a certificate path to a trusted root and return if it can be validated
     * and is trusted for server SSL authentication based on the authentication type.
     *
     * @param chain the peer certificate chain
     * @param authType the key exchange algorithm used
     * @throws CertificateException
     */
    @Override
    public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        checkPeer(chain);
    }

    /**
     * Return an array of certificate authority certificates which are trusted for authenticating peers.
     *
     * @return a non-null (possibly empty) array of acceptable CA issuer certificates
     */
    @Override
    public X509Certificate[] getAcceptedIssuers() {
        return spiffeSVIDManager.getTrustedCerts().toArray(new X509Certificate[0]);
    }

    @Override
    public void checkClientTrusted(X509Certificate[] chain, String authType, Socket socket) throws CertificateException {
        checkClientTrusted(chain, authType);
    }

    @Override
    public void checkServerTrusted(X509Certificate[] chain, String authType, Socket socket) throws CertificateException {
        checkServerTrusted(chain, authType);
    }

    @Override
    public void checkClientTrusted(X509Certificate[] chain, String authType, SSLEngine sslEngine) throws CertificateException {
        checkClientTrusted(chain, authType);
    }

    @Override
    public void checkServerTrusted(X509Certificate[] chain, String authType, SSLEngine sslEngine) throws CertificateException {
        checkServerTrusted(chain, authType);
    }


    /**
     * Validate the trust chain and the SpiffeID
     *
     * @param chain
     * @throws CertificateException
     */
    private void checkPeer(X509Certificate[] chain) throws CertificateException {
        //Check the client certificate chain with our bundle of trusted CAs certificates
        CertificateUtils.validate(chain, spiffeSVIDManager.getTrustedCerts());
        checkSpiffeId(chain);
    }

    /**
     * Validate the peer's SpiffeID using an implementation of ACLService to check
     * whether the SpiffeID is to be trusted
     *
     * @param chain
     * @throws CertificateException
     */
    private void checkSpiffeId(X509Certificate[] chain) throws CertificateException {
        Optional<String> spiffeId = getSpiffeId(chain[0]);
        if (spiffeId.isPresent()) {
            String workloadId = spiffeId.get();

            LOGGER.info("Checking SpiffeID {}", workloadId);
            if (!aclService.isAllowed(workloadId, spiffeSVIDManager.getSpiffeID())) {
                String errorMessage = format("%s is not a trusted service", workloadId);
                LOGGER.error(errorMessage);
                throw new CertificateException(errorMessage);
            }
        } else {
            throw new CertificateException("No Spiffe ID in the certificate");
        }
    }

    private static Logger LOGGER = LoggerFactory.getLogger(SpiffeTrustManager.class);
}
