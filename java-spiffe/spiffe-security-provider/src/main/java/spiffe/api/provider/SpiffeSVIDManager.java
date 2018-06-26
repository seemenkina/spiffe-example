package spiffe.api.provider;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.Validate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import spiffe.api.svid.Fetcher;
import spiffe.api.svid.Workload.X509SVID;
import spiffe.api.svid.X509SvidFetcher;

import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.function.Consumer;

import static java.util.Collections.EMPTY_SET;

/**
 * Handles the instance of Spiffe SVID that represents the identity of the workload
 * It gets automatic updates from the Workload API
 *
 */
public class SpiffeSVIDManager {

    private static Logger LOGGER = LoggerFactory.getLogger(SpiffeSVIDManager.class);

    private static SpiffeSVIDManager INSTANCE;

    public static synchronized SpiffeSVIDManager getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new SpiffeSVIDManager();
        }
        return INSTANCE;
    }

    /**
     * Spiffe Identity handled by this manager
     * It will be updated with the SVID pushed
     * by the Workload API
     *
     */
    private SpiffeSVID spiffeSVID;

    /**
     * Private Constructor
     *
     * Registers a Certificate Updater callback to get the SVID updates from the WorkloadAPI,
     * using the X509SvidFetcher from the java-spiffe library
     *
     */
    private SpiffeSVIDManager() {

        /*
         * Consumer operation that will execute whenever there is a
         * new SVID from the Workload API
         */
        Consumer<List<X509SVID>> certificateUpdater = certs -> {
            Validate.isTrue(certs.size() == 1, "Multiple identities is not supported");
            X509SVID svid  = certs.get(0);
            LOGGER.info("Spiffe ID fetched: " + svid.getSpiffeId());
            spiffeSVID = new SpiffeSVID(svid);
            LOGGER.info("SVID Successfully updated");
        };

        Fetcher<List<X509SVID>> svidFetcher = new X509SvidFetcher();

        svidFetcher.registerListener(certificateUpdater);
    }

    public X509Certificate getSvid() {
        if (spiffeSVID != null) {
            return spiffeSVID.getSvid();
        }
        return null;
    }

    public PrivateKey getPrivateKey() {
        if (spiffeSVID != null) {
            return spiffeSVID.getPrivateKey();
        }
        return null;
    }

    public String getSpiffeID() {
        if (spiffeSVID != null) {
            return spiffeSVID.getSpiffeID();
        }
        return StringUtils.EMPTY;
    }

    @SuppressWarnings("unchecked")
    public Set<X509Certificate> getTrustedCerts() {
        if (spiffeSVID != null) {
            return spiffeSVID.getBundle();
        }
        return EMPTY_SET;
    }
}
