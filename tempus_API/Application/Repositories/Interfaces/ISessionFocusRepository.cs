using Domain.Entities;
using Domain.Base.Repository;

namespace Domain.Repositories.Interfaces
{
    public interface ISessionFocusRepository : IRepositoryBase<SessionFocus>
    {
        public void Insert(SessionFocus sessionFocus);
    }
}
