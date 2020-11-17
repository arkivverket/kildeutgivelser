FROM debian:buster-slim AS prepare

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app
RUN \
	apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y git ca-certificates \
	&& git clone https://github.com/slsfi/digital_edition_tools . --depth=1

FROM node:8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app
COPY --from=prepare /app/client /app
COPY environment.ts /app/src/environments/environment.ts
COPY environment.prod.ts /app/src/environments/environment.prod.ts

RUN npm install

EXPOSE 4200
CMD [ "npx", "ng", "serve", "--host", "0.0.0.0", "--port", "4200", "--disableHostCheck=true" ]
