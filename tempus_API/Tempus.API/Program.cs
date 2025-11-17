using Application.Services.Interfaces;
using Domain.Base;
using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Repositories.Interfaces;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.OpenApi.Models;

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
    options.Authority = $"https://dev-tempus.us.auth0.com/";
    options.Audience = builder.Configuration["AUTH0_CLIENT_AUDIENCE"];
});

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: "AllowAnyOriginPolicy",
                      policy =>
                      {
                          policy.AllowAnyOrigin()
                                .AllowAnyHeader()
                                .AllowAnyMethod();
                      });
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "Tempus API", Version = "v1" });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Please enter 'Bearer' [space] and then your token",
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        BearerFormat = "JWT",
        Scheme = "Bearer"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

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