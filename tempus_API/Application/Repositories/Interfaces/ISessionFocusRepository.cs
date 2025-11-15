using Domain.Entities;
using Domain.Base.Repository;

namespace Domain.Repositories.Interfaces
{
    public interface ISessionFocusRepository : IRepositoryBase
    {
        public void Insert(SessionFocus sessionFocus);
        public void Update(SessionFocus sessionFocus);
        public SessionFocus Get(Guid uuid);
    }
}
