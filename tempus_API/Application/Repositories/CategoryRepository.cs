using Application.Repositories.Interfaces;
using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Entities;

namespace Application.Repositories
{
    public class CategoryRepository(Context context) : RepositoryBase<Category>(context), ICategoryRepository
    {
        public Category GetByID(Guid uuid)
            => base.Get(uuid);

        public new void Insert(Category category)
            => base.Insert(category);

        public new void Delete(Category category)
            => base.Delete(category);

        public List<Category> GetAll(string auth0Identifier)
            => base.GetAll((x) => x.Auth0Identifier == auth0Identifier);
    }
}
