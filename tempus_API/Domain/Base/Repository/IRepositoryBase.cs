namespace Domain.Base.Repository
{
    public interface IRepositoryBase<T1>
    {
        T1 Get(Guid uuid);
        void Update(T1 entity);
    }
}
