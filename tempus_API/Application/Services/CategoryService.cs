using Application.Repositories.Interfaces;
using Application.Services.Interfaces;

namespace Application.Services
{
    public class CategoryService(ICategoryRepository categoryRepository) : ICategoryService
    {
    }
}
