FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:7.0 AS build

ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM

RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

WORKDIR /source

COPY *.csproj .

RUN dotnet restore -a $TARGETARCH

COPY . .

RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore

FROM mcr.microsoft.com/dotnet/runtime:7.0

WORKDIR /app

RUN groupadd -g 10001 app && useradd -u 10001 -g 10001 -m app

COPY --from=build /app .

USER 10001:10001

ENTRYPOINT ["dotnet", "Worker.dll"]
