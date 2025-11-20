namespace Domain.Messaging
{
    public class CreateUserRequest
    {
        public string email { get; set; }
        public string name { get; set; }
        public string auth0_id { get; set; }
    }
}
