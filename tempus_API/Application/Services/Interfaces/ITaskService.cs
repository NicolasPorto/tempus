using Domain.Base;
using Domain.Messaging;

namespace Application.Services.Interfaces
{
    public interface ITaskService : IServiceBase
    {
        void CreateTask(CreateTaskRequest createTaskRequests);
        void FinishTask(Guid taskUUID, bool done);
        List<Domain.Entities.Task> GetAll(string auth0Identifier);
        void DeleteTask(Guid taskUUID);
    }
}
