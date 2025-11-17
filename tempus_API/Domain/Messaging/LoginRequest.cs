namespace Domain.Messaging
{
    public class LoginRequest
    {
        public string email { get; set; }
        public string name { get; set; }
        public string auth0_id { get; set; }
    }
}
