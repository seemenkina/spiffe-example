package spiffe.api.provider;

import javax.net.ssl.SSLEngine;
import javax.net.ssl.X509ExtendedKeyManager;
import java.net.Socket;
import java.security.Principal;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.Objects;

import static spiffe.api.provider.SpiffeProviderConstants.ALIAS;

/**
 * Implementation of the KeyManager for the Spiffe Provider
 * Provides the Certificate Chain and the Private Key of the
 * SVID
 *
 */
public class SpiffeKeyManager extends X509ExtendedKeyManager {

    private SpiffeSVIDManager spiffeSVIDManager;

    SpiffeKeyManager() {
        spiffeSVIDManager = SpiffeSVIDManager.getInstance();
    }

    /**
     * The Certificate Chain that the workload presents to the other peer,
     * it consists only of the SpiffeSVID leaf certificate
     *
     * @return the SVID
     */
    @Override
    public X509Certificate[] getCertificateChain(String s) {
        return new X509Certificate[]{spiffeSVIDManager.getSvid()};
    }

    /**
     * Returns the Private Key associated to the SVID certificate
     *
     * @return the Private Key
     */
    @Override
    public PrivateKey getPrivateKey(String alias) {
        if (!Objects.equals(alias, ALIAS)) {
            return null;
        }
        return spiffeSVIDManager.getPrivateKey();
    }


    @Override
    public String[] getClientAliases(String keyType, Principal[] issuers) {
        return getAliases(keyType);
    }

    @Override
    public String chooseClientAlias(String[] keyTypes, Principal[] issuers, Socket socket) {
        return getAlias(keyTypes);
    }

    @Override
    public String chooseEngineClientAlias(String[] keyTypes, Principal[] issuers, SSLEngine sslEngine) {
        return getAlias(keyTypes);
    }

    @Override
    public String[] getServerAliases(String keyType, Principal[] issuers) {

        return getAliases(keyType);
    }

    @Override
    public String chooseEngineServerAlias(String keyType, Principal[] issuers, SSLEngine sslEngine) {
        return getAlias(keyType);
    }

    @Override
    public String chooseServerAlias(String keyType, Principal[] issuers, Socket socket) {
        return getAlias(keyType);
    }

    /**
     * If the algorithm is supported return the ALIAS of the Provider
     *
     * @param keyTypes
     * @return
     */
    private String getAlias(String ...keyTypes) {
        String idAlgorithm = spiffeSVIDManager.getPrivateKey().getAlgorithm();

        for (String keyType : keyTypes) {
            if (keyType.equals(idAlgorithm)) {
                return ALIAS;
            }
        }

        return null;
    }

    private String[] getAliases(String keyType) {
        String alias = getAlias(keyType);
        return new String[]{alias};
    }
}
