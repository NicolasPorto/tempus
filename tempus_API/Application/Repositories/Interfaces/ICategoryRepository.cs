using Domain.Base.Repository;

namespace Application.Repositories.Interfaces
{
    public interface ICategoryRepository : IRepositoryBase
    {
        Domain.Entities.Category GetByID(Guid uuid);
        void Insert(Domain.Entities.Category category);
        void Delete(Domain.Entities.Category category);
    }
}
