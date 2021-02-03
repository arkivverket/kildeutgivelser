docker build --tag kildeutgivelser/web --file Dockerfile.web .
docker build --tag kildeutgivelser/tei_tools --file Dockerfile.tei_tools .
docker build --tag kildeutgivelser/api --file Dockerfile.api .
docker build --tag kildeutgivelser/pgsql --file Dockerfile.pgsql .
