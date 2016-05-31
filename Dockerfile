FROM alpine:3.3

MAINTAINER Altair Moura <alltairr@gmail.com>

ENV NGINX_VERSION nginx-1.10.0
ENV LUA_JIT_VERSION LuaJIT-2.0.4
ENV NGX_LEVEL_KIT_VERSION ngx_devel_kit-0.3.0
ENV LUA_NGINX_MODULE_VERSION lua-nginx-module-0.10.5

RUN build_pkgs="build-base openssl-dev pcre-dev zlib-dev" \
  && runtime_pkgs="ca-certificates openssl pcre zlib bash" \
  && apk --no-cache add ${build_pkgs} ${runtime_pkgs}

ADD assets/${NGINX_VERSION}.tar.gz /tmp/
ADD assets/${LUA_JIT_VERSION}.tar.gz /tmp/
ADD assets/${NGX_LEVEL_KIT_VERSION}.tar.gz /tmp/
ADD assets/${LUA_NGINX_MODULE_VERSION}.tar.gz /tmp/

RUN echo "Building LuaJit Library" \
    && cd /tmp/${LUA_JIT_VERSION} \
    && make \
    && make PREFIX=/opt/luajit2 install \
    && make clean


RUN echo "Telling to nginx's build system where to find LuaJIT 2.0.4" \
    && export LUAJIT_LIB=/opt/luajit2/lib \
    && export LUAJIT_INC=/opt/luajit2/include/luajit-2.0 \
    && echo "Iniciando compilação do NGINX" \
    && cd /tmp/${NGINX_VERSION} \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx  \
        --modules-path=/usr/lib/nginx/modules  \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_v2_module \
        --with-ld-opt='-Wl,-rpath,/opt/luajit2/lib/' \
        --add-module=/tmp/${NGX_LEVEL_KIT_VERSION} \
        --add-module=/tmp/${LUA_NGINX_MODULE_VERSION} \
    && echo "Configuração do NGINX concluída" \
    && make \
    && make install \
    && make clean \
    && echo "Instalação do NGINX concluída" \
    && apk del ${build_pkgs} \
    && strip -s /usr/sbin/nginx \
    && rm -rf /tmp/ /root/.gnupg \
    && rm -rf /var/cache/apk/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

WORKDIR /etc/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
