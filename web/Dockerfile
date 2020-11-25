FROM nginx:alpine

COPY --from=slsfinland/digital_edition_web:beta-1.1.66 /digital_edition_web/platforms/browser/www/ /var/www/

WORKDIR /var/www

# COPY project_files_web /var/www/
COPY project_files_web/index.html index.html
COPY project_files_web/assets/i18n assets/i18n
COPY project_files_web/assets/midi-files assets/midi-files
COPY project_files_web/assets/jpeg-files assets/jpeg-files
COPY project_files_web/assets/musicxml assets/musicxml
COPY project_files_web/resources resources

ADD nginx.conf /etc/nginx/nginx.conf
ADD gzip.conf /etc/nginx/conf.d/gzip.conf
ADD nginx.default /etc/nginx/conf.d/default.conf

# ENTRYPOINT nginx
