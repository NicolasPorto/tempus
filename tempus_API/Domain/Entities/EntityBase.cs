using System.ComponentModel.DataAnnotations;

namespace Domain.Base
{
    public abstract class EntityBase
    {
        [Key]
        public abstract Guid UUID { get; set; }
    }
}
