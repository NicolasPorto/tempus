using Application.Services.Interfaces;
using Domain.Base;
using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Repositories.Interfaces;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders =
        ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.Authority = $"https://{builder.Configuration["Auth0:Domain"]}/";
    options.Audience = builder.Configuration["Auth0:Audience"];
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<Context>();
builder.Services.AddMemoryCache();

InjectServices(builder.Services);
InjectRepositories(builder.Services);

var app = builder.Build();

app.UseForwardedHeaders();

app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();

void InjectRepositories(IServiceCollection services)
{
    var assembly = typeof(ISessionFocusRepository).Assembly;
    var entityTypes = assembly.GetTypes().Where(type =>
        type.IsClass &&
        !type.IsInterface &&
        type.GetInterfaces().Any((x) => x.IsAssignableFrom(typeof(IRepositoryBase)))
    );

    foreach (var repoType in entityTypes)
    {
        var impType = repoType.GetInterfaces().SingleOrDefault((x) => x != (typeof(IRepositoryBase)) && x.IsAssignableTo((typeof(IRepositoryBase))));
        services.AddTransient(impType, repoType);
    }
}

void InjectServices(IServiceCollection services)
{
    var assembly = typeof(ISessionFocusService).Assembly;
    var entityTypes = assembly.GetTypes().Where(type =>
        type.IsClass &&
        !type.IsInterface &&
        type.GetInterfaces().Any((x) => x.IsAssignableFrom(typeof(IServiceBase)))
    );

    foreach (var servType in entityTypes)
    {
        var impType = servType.GetInterfaces().SingleOrDefault((x) => x != (typeof(IServiceBase)) && x.IsAssignableTo((typeof(IServiceBase))));
        services.AddTransient(impType, servType);
    }
}