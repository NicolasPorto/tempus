using Domain.Base;
using Domain.Messaging;

namespace Application.Services.Interfaces
{
    public interface IUserService : IServiceBase
    {
        void CreateUser(CreateUserRequest createUserRequest);
        public string Authenticate(LoginRequest loginRequest);
    }
}
