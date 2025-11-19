using Domain.Base.Repository;
using Domain.Entities;
using Domain.RawQueries;

namespace Domain.Repositories.Interfaces
{
    public interface ISessionFocusRepository : IRepositoryBase
    {
        public void Insert(SessionFocus sessionFocus);
        public void Update(SessionFocus sessionFocus);
        public SessionFocus Get(Guid uuid);
        public AverageStudyTimeStatsRawQuery ObtainAverageStudiedMinutes(string auth0Identifier);
    }
}
