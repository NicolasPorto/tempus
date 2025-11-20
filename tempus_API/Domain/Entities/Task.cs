using Domain.Base;
using Domain.Messaging;

namespace Domain.Entities
{
    public class Task : EntityBase
    {
        public Task()
        {    
        }

        public Task(CreateTaskRequest createTaskRequests)
        {
            UUID = Guid.NewGuid();
            Name = createTaskRequests.Name;
            MinutesMeta = createTaskRequests.MinutesMeta;
            CategoryUUID = createTaskRequests.CategoryUUID;
            Auth0Identifier = createTaskRequests.Auth0Identifier;
        }

        public override Guid UUID { get; set; }
        public string Name { get; set; }
        public bool Done { get; set; } = false;
        public int MinutesMeta { get; set; } = 25;
        public Guid CategoryUUID { get; set; }
        public string Auth0Identifier { get; set; }
    }
}
