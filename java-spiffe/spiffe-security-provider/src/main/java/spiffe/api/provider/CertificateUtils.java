package spiffe.api.provider;

import org.bouncycastle.jce.provider.BouncyCastleProvider;

import javax.security.auth.x500.X500Principal;
import java.io.ByteArrayInputStream;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.cert.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static java.util.Arrays.asList;
import static java.util.stream.Collectors.toSet;
import static org.apache.commons.lang3.StringUtils.startsWith;

/**
 * Utility class to deal with X509 Certificate creation and PKIX Certificate Validation
 *
 */
public class CertificateUtils {

    private static final CertPathValidator certPathValidator = getCertPathValidator();
    private static final CertificateFactory certificateFactory = getCertificateFactory();

    /**
     * Generate the collection of X509Certificates
     *
     * @param input as byte array
     * @return a Set of X509Certificate
     * @throws CertificateException
     */
    public static Set<X509Certificate> generateCertificates(byte[] input) throws CertificateException {
        Collection<? extends Certificate> certificates =  getCertificateFactory().generateCertificates(new ByteArrayInputStream(input));
        return certificates.stream().map(c -> (X509Certificate) c).collect(toSet());
    }

    /**
     * Generate a single X509Certificate
     *
     * @param input as byte array
     * @return an instance of X509Certificate
     * @throws CertificateException
     */
    public static X509Certificate generateCertificate(byte[] input) throws CertificateException {
        return (X509Certificate) getCertificateFactory().generateCertificate(new ByteArrayInputStream(input));
    }

    /**
     * Generates a PrivateKey from the X509SvidKey ByteArray
     *
     * It uses PKCS8EncodedKeySpec that represents the ASN.1 encoding of a private key
     *
     * @param input as byte array
     * @return
     * @throws NoSuchAlgorithmException
     * @throws InvalidKeySpecException
     */
    public static PrivateKey generatePrivateKey(byte[] input) throws NoSuchAlgorithmException, InvalidKeySpecException {
        KeyFactory keyFactory = KeyFactory.getInstance("EC", new BouncyCastleProvider());
        return keyFactory.generatePrivate(new PKCS8EncodedKeySpec(input));
    }

    /**
     * Extracts the SpiffeID from a SVID - X509Certificate
     *
     * @param certificate
     * @return
     * @throws CertificateParsingException
     */
    public static Optional<String> getSpiffeId(X509Certificate certificate) throws CertificateParsingException {
        return certificate.getSubjectAlternativeNames().stream()
                .map(san -> (String) san.get(1))
                .filter(uri -> startsWith(uri, "spiffe://"))
                .findFirst();
    }


    /**
     * Validate a certificate chain against a set of trusted certificates.
     *
     * @param chain    certificate chain
     * @param trustedCerts
     * @throws CertificateException
     */
    public static void validate(X509Certificate[] chain, Set<X509Certificate> trustedCerts) throws CertificateException {
        PKIXParameters pkixParameters = toPkixParameters(trustedCerts);
        CertPath certPath = certificateFactory.generateCertPath(asList(chain));
        try {
            certPathValidator.validate(certPath, pkixParameters);
        } catch (CertPathValidatorException | InvalidAlgorithmParameterException e) {
            throw new CertificateException(e);
        }
    }

    /**
     * Create an instance of PKIXParameters used as input for the PKIX CertPathValidator
     *
     * @param trustedCerts
     * @return
     * @throws CertificateException
     */
    private static PKIXParameters toPkixParameters(Set<X509Certificate> trustedCerts) throws CertificateException {
        try {
            if (trustedCerts == null || trustedCerts.size() == 0) {
                throw new CertificateException("No trusted Certs");
            }

            PKIXParameters pkixParameters = new PKIXParameters(trustedCerts.stream()
                    .map(c -> new TrustAnchor(c, null))
                    .collect(toSet()));
            pkixParameters.setRevocationEnabled(false);
            return pkixParameters;
        } catch (InvalidAlgorithmParameterException e) {
            throw new IllegalStateException(e);
        }
    }

    /**
     * Get the default PKIX CertPath Validator
     *
     * @return instance of CertPathValidator
     */
    private static CertPathValidator getCertPathValidator() {
        try {
            return CertPathValidator.getInstance(SpiffeProviderConstants.PUBLIC_KEY_INFRASTRUCTURE_ALGORITHM);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    /**
     * Get the X509 Certificate Factory
     *
     * @return instance of CertificateFactory
     */
    private static CertificateFactory getCertificateFactory() {
        try {
            return CertificateFactory.getInstance(SpiffeProviderConstants.X509_CERTIFICATE_TYPE);
        } catch (CertificateException e) {
            throw new IllegalStateException(e);
        }
    }
}
