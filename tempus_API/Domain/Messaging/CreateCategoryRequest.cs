using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Messaging
{
    public class CreateCategoryRequest
    {
        public string Auth0Identifier { get; set; }
        public string Name { get; set; }
        public string HexColor { get; set; }
    }
}
