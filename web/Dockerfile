FROM ghcr.io/bratteng/nginx:mainline

COPY --from=slsfinland/digital_edition_web:2.0 /digital_edition_web/platforms/browser/www/ /var/www/html/public

WORKDIR /var/www/html/public

# COPY project_files_web /var/www/
COPY public/index.html index.html
COPY public/assets/i18n assets/i18n
COPY public/assets/jpeg-files assets/jpeg-files

ADD default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
