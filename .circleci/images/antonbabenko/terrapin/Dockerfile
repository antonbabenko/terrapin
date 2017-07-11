FROM ruby:2.4-alpine

ENV UTIL_PACKAGES bash curl wget openssh-client jq unzip zip ca-certificates git nano
ENV BUILD_PACKAGES curl-dev ruby-dev build-base python-dev
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler
ENV PYTHON_PACKAGES python py-pip
ENV PIP_PACKAGES pip jinja2-cli shyaml awscli
ENV GEM_PACKAGES test-kitchen kitchen-terraform awspec

ENV TF_VERSION=0.9.10

RUN apk update && \
    apk upgrade && \
    apk add --update $UTIL_PACKAGES && \
    apk add --update $BUILD_PACKAGES && \
    apk add --update $RUBY_PACKAGES && \
    apk add --update $PYTHON_PACKAGES

RUN pip install --upgrade $PIP_PACKAGES

RUN gem install $GEM_PACKAGES

RUN wget -q "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" && \
    unzip terraform_${TF_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm -f terraform_${TF_VERSION}_linux_amd64.zip

# Reduce size a tiny bit, but doesn't make much difference given overall size of image
RUN rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

CMD ["/bin/bash"]