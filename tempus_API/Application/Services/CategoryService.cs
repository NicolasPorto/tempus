using Application.Repositories.Interfaces;
using Application.Services.Interfaces;
using Domain.Entities;
using Domain.Messaging;

namespace Application.Services
{
    public class CategoryService(ICategoryRepository categoryRepository) : ICategoryService
    {
        public Guid CreateCategory(CreateCategoryRequest createCategoryRequest)
        {
            var category = 
                new Category(createCategoryRequest);

            categoryRepository.Insert(category);

            return category.UUID;
        }

        public List<Category> ListAll(string auth0Identifier)
            => categoryRepository.GetAll(auth0Identifier);

        public void RemoveCategory(Guid categoryUUID)
        {
            var category = 
                categoryRepository.GetByID(categoryUUID);

            categoryRepository.Delete(category);
        }
    }
}
