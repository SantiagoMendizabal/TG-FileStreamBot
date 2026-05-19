#FROM --platform=$BUILDPLATFORM golang:1.25-alpine3.21 AS builder
#ARG TARGETOS
#ARG TARGETARCH
#WORKDIR /app
#COPY . .
#RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/fsb -ldflags="-w -s" ./cmd/fsb

#FROM scratch
#COPY --from=builder /app/fsb /app/fsb

# Definimos un puerto por defecto para que Docker no se quede vacío al compilar
#ARG PORT=8080
#EXPOSE ${PORT}

# Indicar a Choreo que use un usuario sin privilegios
#USER 10014

#ENTRYPOINT ["/app/fsb", "run"]

FROM --platform=$BUILDPLATFORM golang:1.25-alpine3.21 AS builder

# 1. Instalamos los certificados SSL en la etapa de Alpine
RUN apk add --no-cache ca-certificates

ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY . .

# 2. Compilamos el binario de Go
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/fsb -ldflags="-w -s" ./cmd/fsb

FROM scratch

# 3. Copiamos los certificados SSL para que el bot pueda comunicarse con Telegram
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# 4. Copiamos la carpeta de la app dándole la propiedad total al usuario 10014
COPY --from=builder --chown=10014:10014 /app /app

# 5. Nos posicionamos en la carpeta con permisos para que SQLite pueda crear su base de datos
WORKDIR /app

ARG PORT=8080
EXPOSE ${PORT}

# 6. Indicamos a Choreo el usuario seguro
USER 10014

ENTRYPOINT ["/app/fsb", "run"]
