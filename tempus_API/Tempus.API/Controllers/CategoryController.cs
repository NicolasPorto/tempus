using Application.Services.Interfaces;
using Domain.Exceptions;
using Domain.Messaging;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Tempus.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class CategoryController : ControllerBase
    {
        private readonly ICategoryService _categoryService;

        public CategoryController(ICategoryService categoryService)
        {
            _categoryService = categoryService;
        }

        [HttpPost]
        public IActionResult CreateCategory(CreateCategoryRequest createCategoryRequest)
        {
            try
            {
                var categoryId = _categoryService.CreateCategory(createCategoryRequest);
                return Ok(new ResponseBase
                {
                    Message = categoryId.ToString()
                });
            }
            catch (TempusException temEx)
            {
                return BadRequest(new ResponseBase
                {
                    Message = temEx.Message
                });
            }
            catch (Exception ex)
            {
                return StatusCode((int)HttpStatusCode.InternalServerError);
            }
        }

        [HttpDelete("{categoryUuid}")]
        public IActionResult CreateCategory(Guid categoryUuid)
        {
            try
            {
                _categoryService.RemoveCategory(categoryUuid);
                return Ok();
            }
            catch (TempusException temEx)
            {
                return BadRequest(new ResponseBase
                {
                    Message = temEx.Message
                });
            }
            catch (Exception ex)
            {
                return StatusCode((int)HttpStatusCode.InternalServerError);
            }
        }

        [HttpGet("{auth0Identifier}")]
        public IActionResult CreateCategory(string auth0Identifier)
        {
            try
            {
                var categoryList = _categoryService.ListAll(auth0Identifier);
                return Ok(categoryList);
            }
            catch (TempusException temEx)
            {
                return BadRequest(new ResponseBase
                {
                    Message = temEx.Message
                });
            }
            catch (Exception ex)
            {
                return StatusCode((int)HttpStatusCode.InternalServerError);
            }
        }
    }
}