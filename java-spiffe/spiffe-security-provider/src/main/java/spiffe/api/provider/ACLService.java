package spiffe.api.provider;

public interface ACLService {

    /**
     * Verifies whether the client is allowed to connect with the server
     *
     * Implementations of this interface need to be provided when installing
     * the Spiffe Provider
     *
     * @param clientId
     * @param serverId
     * @return true is the client is allowed to connect with the server
     */
    boolean isAllowed(String clientId, String serverId);
}
