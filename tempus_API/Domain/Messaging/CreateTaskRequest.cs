namespace Domain.Messaging
{
    public class CreateTaskRequest
    {
        public string Name { get; set; }
        public int MinutesMeta { get; set; }
        public Guid CategoryUUID { get; set; }
        public string Auth0Identifier { get; set; }
    }
}
