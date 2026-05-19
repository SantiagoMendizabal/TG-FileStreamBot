FROM --platform=$BUILDPLATFORM golang:1.25-alpine3.21 AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/fsb -ldflags="-w -s" ./cmd/fsb

FROM scratch
COPY --from=builder /app/fsb /app/fsb

# Definimos un puerto por defecto para que Docker no se quede vacío al compilar
ARG PORT=8080
EXPOSE ${PORT}

# Indicar a Choreo que use un usuario sin privilegios
USER 10014

ENTRYPOINT ["/app/fsb", "run"]
