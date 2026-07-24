FROM frappe/erpnext:v16.29.0

USER root
RUN apt-get update \
    && apt-get install --no-install-recommends -y git \
    && rm -rf /var/lib/apt/lists/*

USER frappe
WORKDIR /home/frappe/frappe-bench

ARG WOOCOMMERCE_FUSION_REPO=https://github.com/Starktail/woocommerce_fusion.git
ARG WOOCOMMERCE_FUSION_BRANCH=version-15

RUN bench get-app --branch ${WOOCOMMERCE_FUSION_BRANCH} ${WOOCOMMERCE_FUSION_REPO}
RUN bench build --app woocommerce_fusion
