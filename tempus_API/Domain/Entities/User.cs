using Domain.Base;
using Domain.Entities.Enums;
using Domain.Messaging;

namespace Domain.Entities
{
    public class User : EntityBase
    {
        public override Guid UUID { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Auth0Identifier { get; set; }
        public SubscriptionType SubscriptionType { get; set; }
        public User() {}

        public User(Auth0.ManagementApi.Models.User userAuth0)
        {
            UUID = Guid.NewGuid();
            Name = userAuth0.FullName;
            Email = userAuth0.Email;
            Auth0Identifier = userAuth0.UserId;
            SubscriptionType = SubscriptionType.Free;
        }
    }
}
