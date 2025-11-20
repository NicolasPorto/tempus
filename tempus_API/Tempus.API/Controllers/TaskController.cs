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
    public class TaskController : ControllerBase
    {
        private readonly ITaskService _taskService;

        public TaskController(ITaskService taskService)
        {
            _taskService = taskService;
        }

        [HttpPost]
        public IActionResult CreateTask(CreateTaskRequest createTaskRequest)
        {
            try
            {
                _taskService.CreateTask(createTaskRequest);
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

        [HttpPost("toggle/{taskUuid}")]
        public IActionResult FinishTask(Guid taskUuid, [FromQuery] bool done)
        {
            try
            {
                _taskService.FinishTask(taskUuid, done);
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

        [HttpDelete("{taskUuid}")]
        public IActionResult DeleteTask(Guid taskUuid)
        {
            try
            {
                _taskService.DeleteTask(taskUuid);
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
        public IActionResult GetAll(string auth0Identifier)
        {
            try
            {
                var taskList = _taskService.GetAll(auth0Identifier);
                return Ok(taskList);
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