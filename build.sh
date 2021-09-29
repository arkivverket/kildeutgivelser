docker build --tag kildeutgivelser/web --file Dockerfile.web .
docker build --tag kildeutgivelser/tei_tools --file Dockerfile.tei_tools .
docker build --tag kildeutgivelser/api --file Dockerfile.api .
docker build --tag kildeutgivelser/pgsql --file Dockerfile.pgsql .
docker build --tag kildeutgivelser/svn --file Dockerfile.svn .
docker build --tag kildeutgivelser/jetty --file Dockerfile.jetty .
docker build --tag kildeutgivelser/mysql --file Dockerfile.mysql .
docker build --tag kildeutgivelser/svn_sync --file Dockerfile.svn_sync .
