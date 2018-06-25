package spiffe.api.provider;

import com.google.common.collect.ImmutableList;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.*;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.time.Instant;
import java.util.*;

import static java.util.Collections.enumeration;
import static spiffe.api.provider.SpiffeProviderConstants.ALIAS;

/**
 * This class is required for the Java Provider Architecture,
 * but it doesn't handle the Certificates, but it only returns
 * the ALIAS that is handled by the Provider
 *
 */
public class SpiffeKeyStore extends KeyStoreSpi {

    @Override
    public Key engineGetKey(String alias, char[] password) {
        return null;
    }

    @Override
    public Certificate[] engineGetCertificateChain(String alias) {
        return null;
    }

    @Override
    public Certificate engineGetCertificate(String alias) {
        return null;
    }

    @Override
    public Date engineGetCreationDate(String alias) {
        return Date.from(Instant.now());
    }

    @Override
    public void engineSetKeyEntry(String alias, Key key, char[] password, Certificate[] chain) throws KeyStoreException {

    }

    @Override
    public void engineSetKeyEntry(String alias, byte[] key, Certificate[] chain) throws KeyStoreException {

    }

    @Override
    public void engineSetCertificateEntry(String alias, Certificate cert) throws KeyStoreException {

    }

    @Override
    public void engineDeleteEntry(String alias) throws KeyStoreException {

    }

    @Override
    public Enumeration<String> engineAliases() {
        return enumeration(ImmutableList.of(ALIAS));
    }

    @Override
    public boolean engineContainsAlias(String alias) {
        return Objects.equals(alias, ALIAS);
    }

    @Override
    public int engineSize() {
        return 1;
    }

    @Override
    public boolean engineIsKeyEntry(String alias) {
        return Objects.equals(alias, ALIAS);
    }

    @Override
    public boolean engineIsCertificateEntry(String alias) {
        return Objects.equals(alias, ALIAS);
    }

    @Override
    public String engineGetCertificateAlias(Certificate cert) {
        return ALIAS;
    }

    @Override
    public void engineStore(OutputStream stream, char[] password) throws IOException, NoSuchAlgorithmException, CertificateException {

    }

    @Override
    public void engineLoad(InputStream stream, char[] password) throws IOException, NoSuchAlgorithmException, CertificateException {

    }
}
