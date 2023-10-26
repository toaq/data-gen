FROM alpine AS build-stage
RUN apk add --no-cache curl findutils jq make python3

WORKDIR /work
COPY . .
RUN make

FROM scratch AS export-stage
COPY --from=build-stage /work/data /data
