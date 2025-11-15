using Application.Repositories.Interfaces;
using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Application.Repositories
{
    public class UserRepository(Context context) : RepositoryBase<User>(context), IUserRepository
    {
        void IUserRepository.Insert(User userEntity) => base.Insert(userEntity);
    }
}
