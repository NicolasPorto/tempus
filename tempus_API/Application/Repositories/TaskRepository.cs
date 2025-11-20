using Application.Repositories.Interfaces;
using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Entities;
using Domain.Repositories.Interfaces;

namespace Application.Repositories
{
    public class TaskRepository : RepositoryBase<Domain.Entities.Task>, ITaskRepository
    {
        public TaskRepository(Context context) : base(context)
        {
        }

        public List<Domain.Entities.Task> GetAll(string auth0Identifier)
            => base.GetAll((x) => x.Auth0Identifier == auth0Identifier);

        Domain.Entities.Task ITaskRepository.GetByUuid(Guid uuid) 
            => base.Get(uuid);
    }
}
