package spiffe.api.provider;

import spiffe.api.svid.Workload;

import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.Date;
import java.util.Set;

import static java.util.stream.Collectors.toSet;

/**
 * Represents a Spiffe Identity
 *
 * spiffeId: the SPIFFE identity string
 * svid: SPIFFE Verifiable Identity Document
 * privateKey: The Private Key associated to the Public Key of the SVID
 * bundle: the trust chain that is used as the set of CAs trusted certificates
 *
 * It is constructed from an instance of Workload.X509SVID that carries
 * the ByteArrays containing the private key, SVID and bundle. The ByteArrays
 * are converted to java.security.cert.X509Certificate and java.security.PrivateKey
 *
 */
public class SpiffeSVID {

    private String spiffeID;
    private X509Certificate svid;
    private PrivateKey privateKey;
    private Set<X509Certificate> bundle;

    /**
     * Constructor
     *
     * @param x509SVID: Workload.X509SVID gRPC message
     */
    public SpiffeSVID(Workload.X509SVID x509SVID) {
        try {
            svid = CertificateUtils.generateCertificate(x509SVID.getX509Svid().toByteArray());

            bundle = CertificateUtils.generateCertificates(x509SVID.getBundle().toByteArray());
            bundle = filterOutdated(bundle);

            privateKey = CertificateUtils.generatePrivateKey(x509SVID.getX509SvidKey().toByteArray());
            spiffeID = x509SVID.getSpiffeId();
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }

    /**
     * Returns a Set of certificates that are not expired
     *
     * @param certs Set of X509Certificate
     * @return Set of X509Certificate filtering the outdated ones
     */
    private Set<X509Certificate> filterOutdated(Set<X509Certificate> certs) {
        return certs.stream()
                .filter(c -> c.getNotAfter().after(new Date()))
                .collect(toSet());
    }

    public X509Certificate getSvid() {
        return svid;
    }

    public PrivateKey getPrivateKey() {
        return privateKey;
    }

    public Set<X509Certificate> getBundle() {
        return bundle;
    }

    public String getSpiffeID() {
        return spiffeID;
    }

}
