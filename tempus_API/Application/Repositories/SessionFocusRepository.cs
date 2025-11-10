using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Entities;
using Domain.Repositories.Interfaces;

namespace Infra.Repositories
{
    public class SessionFocusRepository : RepositoryBase<SessionFocus>, ISessionFocusRepository
    {
        public SessionFocusRepository(Context context) : base(context)
        {
        }
    }
}
