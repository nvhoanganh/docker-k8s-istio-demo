FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
COPY ["backendapi.csproj", "./"]
RUN dotnet restore "./backendapi.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "backendapi.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "backendapi.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "backendapi.dll"]
