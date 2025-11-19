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
                var sessionUuid = _sessionFocusService.InitiateFocus(initiateFocusRequest);
                return Ok(sessionUuid);
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

        [HttpPost("inform-distraction/{sessionUUID}")]
        public IActionResult InformUnfocusedTime(Guid sessionUUID, int minutesOnfocused)
        {
            try
            {
                _sessionFocusService.InformUnfocusedTime(sessionUUID, minutesOnfocused);
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

        [HttpPut("stop/{sessionUUID}")]
        public IActionResult StopSession(Guid sessionUUID)
        {
            try
            {
                _sessionFocusService.StopFocus(sessionUUID);
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

        [HttpGet("stats/average/{auth0Identifier}")]
        public IActionResult StopSession(string auth0Identifier)
        {
            try
            {
                var avgRawQuery = _sessionFocusService.ObtainAverageStudiedMinutes(auth0Identifier);
                return Ok(avgRawQuery);
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
