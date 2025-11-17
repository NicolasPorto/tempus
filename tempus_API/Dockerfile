# ----- Estágio 1: Build & Restore -----
# Usamos a imagem SDK (completa) para compilar a aplicação
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia o arquivo da Solution e TODOS os arquivos .csproj
# Isso é otimizado para o cache do Docker
COPY Tempus.API.sln .
COPY Application/Application.csproj Application/
COPY Domain/Domain.csproj Domain/
COPY Infra/Infra.csproj Infra/
COPY Tempus.API/Tempus.API.csproj Tempus.API/

# Restaura os pacotes NuGet para a SOLUTION INTEIRA
RUN dotnet restore "Tempus.API.sln"

# Copia todo o resto do código-fonte e compila
COPY . .
RUN dotnet publish "Tempus.API/Tempus.API.csproj" -c Release -o /app/publish

# ----- Estágio 2: Imagem Final -----
# Usamos a imagem ASP.NET (menor) para rodar a aplicação
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

# Garante que o Kestrel escute em 0.0.0.0 (obrigatório para containers)
# E expõe a porta 8080, que é a padrão do Fly.io
ENV ASPNETCORE_URLS=http://*:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Tempus.API.dll"]