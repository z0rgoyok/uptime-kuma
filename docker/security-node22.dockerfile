# Build the deployed 1.23.17 application from the managed fork.
FROM node:22.23.4-bookworm-slim AS node_runtime
FROM louislam/uptime-kuma:base-debian AS build
COPY --from=node_runtime /usr/local/bin/node /usr/local/bin/node
WORKDIR /app
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 CYPRESS_INSTALL_BINARY=0
COPY .npmrc package.json package-lock.json ./
RUN node --version && npm ci
COPY . .
RUN npm run build && npm prune --omit=dev && npm cache clean --force

FROM louislam/uptime-kuma:base-debian AS release
COPY --from=node_runtime /usr/local/bin/node /usr/local/bin/node
WORKDIR /app
ENV UPTIME_KUMA_IS_CONTAINER=1
COPY --from=build /app /app
RUN node --version && chmod +x extra/entrypoint.sh
EXPOSE 3001
VOLUME ["/app/data"]
HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD node -e "require('http').get('http://127.0.0.1:3001/',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"
ENTRYPOINT ["/usr/bin/dumb-init", "--", "extra/entrypoint.sh"]
CMD ["node", "server/server.js"]
