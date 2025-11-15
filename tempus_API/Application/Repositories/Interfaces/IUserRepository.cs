using Auth0.ManagementApi.Models.Rules;
using Domain.Base.Repository;

namespace Application.Repositories.Interfaces
{
    public interface IUserRepository : IRepositoryBase
    {
        public void Insert(Domain.Entities.User userEntity);
    }
}
