package spiffe.api.provider;

import java.security.Provider;
import java.security.Security;

import static spiffe.api.provider.SpiffeProviderConstants.PROVIDER_NAME;

/**
 * This class represents a "provider" for the
 * Java Security API, that implements a
 * KeyStore/TrustStore Manager that supports
 * Spiffe SVID retrieval and SpiffeID validation
 *
 */
public class SpiffeProvider extends Provider {

    /**
     * Constructor
     *
     * Configure the Provider Name and register KeyManagerFactory, TrustManagerFactory and KeyStore
     *
     */
    public SpiffeProvider() {
        super(PROVIDER_NAME, 0.1, "");
        super.put("KeyManagerFactory."+ SpiffeProviderConstants.ALGORITHM, SpiffeKeyManagerFactory.class.getName());
        super.put("TrustManagerFactory." + SpiffeProviderConstants.ALGORITHM, SpiffeTrustManagerFactory.class.getName());
        super.put("KeyStore." + SpiffeProviderConstants.ALGORITHM, SpiffeKeyStore.class.getName());
    }

    public static synchronized void install(Class<? extends ACLService> aclService) {
        Security.setProperty("ssl.KeyManagerFactory.algorithm", SpiffeProviderConstants.ALGORITHM);
        Security.setProperty("ssl.TrustManagerFactory.algorithm", SpiffeProviderConstants.ALGORITHM);

        //Register the ACLService implementation
        Security.setProperty("ssl.ACLService", aclService.getTypeName());

        Security.addProvider(new SpiffeProvider());
    }
}
