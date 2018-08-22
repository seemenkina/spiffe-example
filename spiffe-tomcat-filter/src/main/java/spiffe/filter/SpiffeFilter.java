package spiffe.filter;

import java.io.IOException;
import java.security.cert.CertificateParsingException;
import java.security.cert.X509Certificate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletResponse;

import static org.apache.commons.lang3.StringUtils.startsWith;

@WebFilter("/SpiffeFilter")
public class SpiffeFilter implements Filter {

	private static final String X509 = "javax.servlet.request.X509Certificate";
	private static final String ACCEPT_SPIFFE_ID_PARAM = "accept-spiffe-id";
	private static final String SPIFFE_PREFIX = "spiffe://";
	private static final int SAN_VALUE_INDEX = 1;

	private ServletContext context;
	private String acceptSpiffeId;
	
	public void init(FilterConfig fConfig) throws ServletException {
		this.context = fConfig.getServletContext();
		this.context.log("SPIFFE Filter initialized");

		acceptSpiffeId = fConfig.getInitParameter(ACCEPT_SPIFFE_ID_PARAM);
	}

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		HttpServletResponse httpServletResponse = (HttpServletResponse) response;
		X509Certificate[] certificates = (X509Certificate[]) request.getAttribute(X509);
		if (certificates.length > 0) {
			try {
				Optional<String> spiffeID = getSpiffeId(certificates[0]);

				if (!spiffeID.isPresent()) {
					throw new IllegalAccessError("SpiffeID not found");
				}

				if (!spiffeID.get().equals(acceptSpiffeId)) {
					httpServletResponse.sendError(HttpServletResponse.SC_FORBIDDEN);
					throw new IllegalAccessError("SpiffeID not authorized");
				}
			} catch (CertificateParsingException e) {
				e.printStackTrace();
			}
		}

		// pass the request along the filter chain
		chain.doFilter(request, response);
	}


	private Optional<String> getSpiffeId(X509Certificate certificate) throws CertificateParsingException {
		List<String> spiffeIds = certificate.getSubjectAlternativeNames().stream()
				.map(san -> (String) san.get(SAN_VALUE_INDEX))
				.filter(uri -> startsWith(uri, SPIFFE_PREFIX))
				.collect(Collectors.toList());
		if (spiffeIds.size() > 1) {
			throw new IllegalArgumentException("Certificate contains multiple SpiffeID. Not Supported ");
		}
		return spiffeIds.stream().findFirst();
	}

}
