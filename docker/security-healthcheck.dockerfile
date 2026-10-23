# Metadata-only repair; verify the managed base image ID before/after build.
# Base: sha256:d65456d80d7a841433d6a9ba8cf562bf230ca5a898d8921488b10a2da7a457b1
FROM ghcr.io/z0rgoyok/uptime-kuma:1.23.17-node22.23.4-ee267be9
HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD node -e "require('http').get('http://127.0.0.1:3001/dashboard',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"
