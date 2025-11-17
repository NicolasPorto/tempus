using Domain.Base;
using Domain.Entities.Enums;
using Domain.Messaging;

namespace Domain.Entities
{
    public class User : EntityBase
    {
        public override Guid UUID { get; set; }
        public string Email { get; set; }
        public string Auth0Identifier { get; set; }
        public SubscriptionType SubscriptionType { get; set; }
        public User() {}

        public User(CreateUserRequest userAuth0)
        {
            UUID = Guid.NewGuid();
            Email = userAuth0.email;
            Auth0Identifier = userAuth0.auth0_id;
            SubscriptionType = SubscriptionType.Free;
        }
    }
}
