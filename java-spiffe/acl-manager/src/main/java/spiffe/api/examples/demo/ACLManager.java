package spiffe.api.examples.demo;

import org.apache.commons.lang3.Validate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import static java.util.stream.Collectors.toList;
import static org.apache.commons.lang3.StringUtils.isBlank;

/**
 * Class to handle the List of Allowed Spiffe IDs
 */
public class ACLManager {

    private final String TRUSTED_SERVICES_FILE = "trusted.services.list";

    private static ACLManager INSTANCE;

    public static ACLManager getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new ACLManager();
        }
        return INSTANCE;
    }

    private List<String> ALLOWED_SPIFFE_IDS;

    /**
     * Private Constructor
     *
     * Read the file and update the List of Allowed Spiffe IDs
     * Configure a TimerTask to check changes on the file
     * and update the list of Spiffe IDs
     *
     */
    private ACLManager() {
        String aclFile = System.getProperty(TRUSTED_SERVICES_FILE);
        Validate.isTrue(!isBlank(aclFile), "Trusted Services list file is not configured");
        ALLOWED_SPIFFE_IDS = loadList(aclFile);

        //Configure ACL list Updater
        TimerTask updateTask = new FileWatcher(new File(aclFile)) {
            protected void onChange(File file) {
                LOGGER.info("File " + file.getName() + " have change. Updating ACL List");
                ALLOWED_SPIFFE_IDS = loadList(aclFile);
            }
        };
        Timer timer = new Timer();
        //Check updates every second
        timer.schedule(updateTask, new Date(), 1000 );
    }

    /**
     * Check whethe the spiffeID is in the list of Allowed Spiffe IDs
     * @param spiffeId
     * @return
     */
    public boolean isAllowed(String spiffeId) {
        return ALLOWED_SPIFFE_IDS.contains(spiffeId);
    }

    /**
     * Load list of String from 'aclFile'
     * @param aclFile
     * @return
     */
    private List<String> loadList(String aclFile) {
        try (BufferedReader br = new BufferedReader(new FileReader(aclFile))) {
            return br.lines().collect(toList());
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
    }

    private static Logger LOGGER = LoggerFactory.getLogger(ACLManager.class);
}
