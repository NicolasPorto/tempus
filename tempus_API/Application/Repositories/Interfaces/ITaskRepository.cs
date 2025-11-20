using Domain.Base.Repository;
using Domain.Entities;

namespace Application.Repositories.Interfaces
{
    public interface ITaskRepository : IRepositoryBase
    {
        void Insert(Domain.Entities.Task task);
        void Update(Domain.Entities.Task task);
        void Delete(Domain.Entities.Task task);
        List<Domain.Entities.Task> GetAll(string auth0Identifier);
        Domain.Entities.Task GetByUuid(Guid uuid);
    }
}
