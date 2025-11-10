using Application.Services.Interfaces;
using Domain.Base;
using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddDbContext<Context>();

InjectServices(builder.Services);
InjectRepositories(builder.Services);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

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