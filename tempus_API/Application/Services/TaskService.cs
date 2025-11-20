using Application.Repositories.Interfaces;
using Application.Services.Interfaces;
using Domain.Messaging;

namespace Application.Services
{
    public class TaskService(ITaskRepository taskRepository) : ITaskService
    {
        public void CreateTask(CreateTaskRequest createTaskRequests)
        {
            var newTask = 
                new Domain.Entities.Task(createTaskRequests);

            taskRepository.Insert(newTask);
        }

        public void DeleteTask(Guid taskUUID)
        {
            var task =
                taskRepository.GetByUuid(taskUUID);

            taskRepository.Delete(task);
        }

        public void FinishTask(Guid taskUUID)
        {
            var task =
                taskRepository.GetByUuid(taskUUID);

            task.Done = true;
            taskRepository.Update(task);
        }

        public List<Domain.Entities.Task> GetAll(string auth0Identifier)
            => taskRepository.GetAll(auth0Identifier);
    }
}
