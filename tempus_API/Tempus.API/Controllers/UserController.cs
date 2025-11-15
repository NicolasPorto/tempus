using Application.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Tempus.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly ILogger<UserController> _logger;

        public UserController(IUserService userService, ILogger<UserController> logger)
        {
            _userService = userService;
            _logger = logger;
        }

        [HttpPost]
        public IActionResult CreateUser(Domain.Messaging.CreateUserRequest createUserRequest)
        {
            try
            {
                _userService.CreateUser(createUserRequest);
                return Ok();
            }
            catch (Domain.Exceptions.TempusException temEx)
            {
                return BadRequest(new Domain.Messaging.ResponseBase
                {
                    Message = temEx.Message
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unexpected error occurred while creating a user.");
                return StatusCode((int)System.Net.HttpStatusCode.InternalServerError);
            }
        }
    }
}
