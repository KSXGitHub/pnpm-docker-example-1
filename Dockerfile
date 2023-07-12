FROM node:20-slim AS pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM pnpm AS prod-deps
COPY . /app
WORKDIR /app
RUN pnpm install --prod --frozen-lockfile

FROM prod-deps AS build
RUN pnpm install --frozen-lockfile
RUN pnpm run build

FROM node:20-slim
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
COPY package.json /app/package.json
WORKDIR /app
CMD [ "node", "dist/index.js" ]
