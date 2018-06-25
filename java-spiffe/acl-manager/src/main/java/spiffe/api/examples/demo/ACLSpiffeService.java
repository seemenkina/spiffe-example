package spiffe.api.examples.demo;

import spiffe.api.provider.ACLService;

public class ACLSpiffeService implements ACLService {

    @Override
    public boolean isAllowed(String clientId, String serverId) {
        return ACLManager.getInstance().isAllowed(clientId);
    }
}
