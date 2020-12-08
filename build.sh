docker build --tag kildeutgivelser/web --file Dockerfile.web .
docker build --tag kildeutgivelser/api_proxy --file Dockerfile.api_proxy .
docker build --tag kildeutgivelser/tei_tools --file Dockerfile.tei_tools .
docker build --tag kildeutgivelser/api --file Dockerfile.api .
