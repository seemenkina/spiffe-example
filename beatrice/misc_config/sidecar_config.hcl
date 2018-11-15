agentAddress = "/tmp/agent.sock"
ghostunnelCmd = "$HOME/go/bin/ghostunnel"
ghostunnelArgs = "server --listen 0.0.0.0:33306 --target localhost:3306 --allow-uri-san spiffe://example.org/Blog"
certDir = "$HOME"
