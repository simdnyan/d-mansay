FROM alpine:edge AS Builder

RUN apk --no-cache add build-base git \
 && apk --no-cache add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing ldc ldc-static dtools-rdmd dub
COPY . /root/project/
WORKDIR /root/project/
RUN dub build --compiler=ldc2
RUN dub build --compiler=ldc2 --config=think

# Runner
FROM alpine:edge

COPY --from=Builder /root/project/d-mansay /usr/bin/d-mansay
COPY --from=Builder /root/project/d-manthink /usr/bin/d-manthink
COPY ./entrypoint.sh /usr/bin/entrypoint.sh
RUN apk --no-cache add libexecinfo libgcc
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
