using Application.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using static Org.BouncyCastle.Math.EC.ECCurve;

namespace Tempus.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IConfiguration _config;
        private readonly ILogger<UserController> _logger;

        public UserController(IUserService userService, ILogger<UserController> logger, IConfiguration config)
        {
            _userService = userService;
            _logger = logger;
            _config = config;
        }

        [HttpPost("sync")]
        public IActionResult CreateUser(Domain.Messaging.CreateUserRequest createUserRequest)
        {
            try
            {
                if (!ValidateApiKey())
                    return Unauthorized();

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

        private bool ValidateApiKey()
        {
            var authHeader = Request.Headers["Authorization"].FirstOrDefault();
            var expectedSecret = _config.GetValue<string>("ApiKey");

            if (authHeader == null || !authHeader.StartsWith("Bearer ") || authHeader.Contains(expectedSecret))
                return false;

            return true;
        }
    }
}
