FROM python:3.9.7-slim AS prepare
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
	# Adds poetry bin to $PATH, so we don't need to link it to /usr/local/bin
	PATH=/opt/poetry/bin:${PATH}

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
        curl \
        git \
    \
    && curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

WORKDIR /app
COPY poetry.lock /app
COPY pyproject.toml /app
RUN poetry config virtualenvs.in-project true \
	&& poetry install --no-dev

FROM python:3.9.7-slim

ENV PATH=/app/.venv/bin:${PATH}

RUN \
	apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
		subversion \
		gettext \
		git

RUN \
	mkdir -p ~/.config/git \
	&& mkdir -p ~/.ssh \
	&& git config --global credential.helper "store --file ~/.config/git/credentials" \
	&& git config --global user.name "arkivverketbot" \
	&& git config --global user.email "arkivverketbot@arkivverket.no" \
	&& git config --global core.quotepath off \
	&& git config --global pull.ff only

COPY credentials.template /
COPY 11-envsubst-git-credentials.sh /docker-entrypoint.d/
COPY docker-entrypoint.sh /
COPY app/ /app/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [ "python", "-m", "app.main" ]
