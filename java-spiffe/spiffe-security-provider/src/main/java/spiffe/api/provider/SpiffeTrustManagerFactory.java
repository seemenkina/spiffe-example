package spiffe.api.provider;

import javax.net.ssl.ManagerFactoryParameters;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactorySpi;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyStore;
import java.security.KeyStoreException;

public class SpiffeTrustManagerFactory extends TrustManagerFactorySpi {
    @Override
    protected void engineInit(KeyStore keyStore) {

    }

    @Override
    protected void engineInit(ManagerFactoryParameters managerFactoryParameters) {

    }

    @Override
    protected TrustManager[] engineGetTrustManagers() {
        return new TrustManager[] {new SpiffeTrustManager()};
    }
}
