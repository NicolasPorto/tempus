using Microsoft.EntityFrameworkCore;

namespace Domain.Base.Repository;

public abstract class RepositoryBase<T1>(DbContext context) : IRepositoryBase<T1> where T1 : EntityBase
{
    private DbSet<T1> contextSet = context.Set<T1>();

    public T1 Get(Guid uuid) => contextSet.AsNoTrackingWithIdentityResolution().SingleOrDefault((x) => x.UUID == uuid);
    public void Insert(T1 entity)
    {
        contextSet.Add(entity);
        context.SaveChanges();
    }

    public void Update(T1 entity)
    {
        contextSet.Update(entity);
        context.SaveChanges();
    }

    public void Delete(T1 entity)
    {
        contextSet.Remove(entity);
        context.SaveChanges();
    }

    public List<T2> RawQuery<T2>(string sql, params object[] parameters) where T2 : class
    {
        return context.Database.SqlQueryRaw<T2>(sql, parameters).AsNoTracking()?.ToList();
    }
}