using Domain.Base;
using Domain.Messaging;

namespace Domain.Entities
{
    public class Category : EntityBase
    {
        public override Guid UUID { get; set; }
        public string Name { get; set; }
        public string HexColor { get; set; }
        public string Auth0Identifier { get; set; }

        public Category()
        {
                
        }

        public Category(CreateCategoryRequest req)
        {
            UUID = Guid.NewGuid();
            Name = req.Name;
            HexColor = req.HexColor;
            Auth0Identifier = req.Auth0Identifier;
        }
    }
}
