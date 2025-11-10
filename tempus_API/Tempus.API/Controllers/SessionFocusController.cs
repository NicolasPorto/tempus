using Application.Services;
using Application.Services.Interfaces;
using Domain.Messaging;
using Domain.Exceptions;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Tempus.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SessionFocusController : ControllerBase
    {
        private readonly ISessionFocusService _sessionFocusService;
        private readonly ILogger<SessionFocusController> _logger;

        public SessionFocusController(ISessionFocusService sessionFocusService, ILogger<SessionFocusController> logger)
        {
            _sessionFocusService = sessionFocusService;
            _logger = logger;
        }

        [HttpPost]
        public IActionResult InitiateFocus(InitiateFocusRequest initiateFocusRequest)
        {
            try
            {
                _sessionFocusService.InitiateFocus(initiateFocusRequest);
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
    }
}
