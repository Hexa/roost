ARG target=ubuntu-18.04

FROM hexa/crystal:$target AS builder
MAINTAINER Hexa <hexa.diary@gmail.com>

ARG branch=develop

RUN git clone -b $branch https://github.com/Hexa/roost.git

WORKDIR /roost

RUN make all

FROM scratch

COPY --from=builder /roost/roost /roost
