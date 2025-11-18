using Domain.Base;
using Domain.Entities;
using Domain.Messaging;

namespace Application.Services.Interfaces
{
    public interface ICategoryService : IServiceBase
    {
        public void CreateCategory(CreateCategoryRequest createCategoryRequest);
        public void RemoveCategory(Guid categoryUUID);
        public List<Category> ListAll(string auth0Identifier);
    }
}
