# Build Stage
FROM odoo:14.0 as builder

WORKDIR /app

USER root

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 不编译Rust
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1 


RUN sed -i 's/http:\/\/deb.debian.org\/debian/https:\/\/mirrors.tuna.tsinghua.edu.cn\/debian/g' /etc/apt/sources.list \ 
  && apt-get update \
#  && apt-get install -y --no-install-recommends gcc libpq-dev build-essential python3-pip python3-venv python3-wheel
  && apt-get install -y gcc build-essential libssl-dev libffi-dev \
  && apt-get install -y libsasl2-dev libldap2-dev libssl-dev \
  && apt-get install -y python-dev python3-dev python3-wheel \
  && pip3 install wheel


COPY requirements.txt .
RUN pip3 wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple


# Run Stage
FROM odoo:14.0 as runtime 
MAINTAINER CFSoft <http://www.khcloud.net>

USER root

RUN sed -i 's/http:\/\/deb.debian.org\/debian/https:\/\/mirrors.tuna.tsinghua.edu.cn\/debian/g' /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y python3-dev procps vim 

COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

#RUN pip3 install --no-cache /wheels/* -i  https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 install --no-cache /wheels/* --no-index --find-links=/wheels \
  && rm -rf /wheels


RUN ln -s /usr/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7.so /usr/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7m.so.1.0


