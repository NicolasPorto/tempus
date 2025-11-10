using Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Domain.Base.Repositories
{
    public class Context : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                var connStr = "Server=hopper.proxy.rlwy.net;Port=30420;Database=tempus;Uid=root;Pwd=yGsRLEqZFwnwtrGWnySEXusfexCKNxHO;AllowPublicKeyRetrieval=true;";
                optionsBuilder.UseMySQL(connStr);
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            var assembly = typeof(SessionFocus).Assembly;

            var entityTypes = assembly.GetTypes().Where(type =>
                type.IsClass &&
                !type.IsAbstract &&
                typeof(EntityBase).IsAssignableFrom(type)
            );

            foreach (var entityType in entityTypes)
            {
                modelBuilder.Entity(entityType);
            }
        }
    }
}
