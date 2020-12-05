docker buildx build --tag kildeutgivelser/web --file Dockerfile.web .
docker buildx build --tag kildeutgivelser/api_proxy --file Dockerfile.api_proxy .
docker buildx build --tag kildeutgivelser/tei_tools --file Dockerfile.tei_tools .
docker buildx build --tag kildeutgivelser/api --file Dockerfile.api .
