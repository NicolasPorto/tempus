using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Entities;
using Domain.RawQueries;
using Domain.Repositories.Interfaces;
using MySql.Data.MySqlClient;

namespace Infra.Repositories
{
    public class SessionFocusRepository : RepositoryBase<SessionFocus>, ISessionFocusRepository
    {
        public SessionFocusRepository(Context context) : base(context)
        {
        }

        void ISessionFocusRepository.Insert(SessionFocus sessionFocus) => base.Insert(sessionFocus);
        void ISessionFocusRepository.Update(SessionFocus sessionFocus) => base.Update(sessionFocus);
        SessionFocus ISessionFocusRepository.Get(Guid uuid) => base.Get(uuid);

        public AverageStudyTimeStatsRawQuery ObtainAverageStudiedMinutes(string auth0Identifier)
        {
            const string sql =
                """
                    SELECT
                	AVG(TIMESTAMPDIFF(MINUTE, sf.StartDttime, sf.FinishDttime)) 'TimeStudied',
                	SUM(MINUTE(sf.FinishDttime)) 'TotalTimeStudied',
                	SUM(MINUTE(sf.SupposedFinish)) 'SupposedTotalTimeStudied'
                FROM
                	SessionFocus sf
                WHERE
                	sf.FinishDtTime IS NOT NULL
                	AND sf.Auth0Identifier = @auth0Identifier
                """;
            var param = new MySqlParameter("@auth0Identifier", auth0Identifier);
            return RawQuery<AverageStudyTimeStatsRawQuery>(sql, param).SingleOrDefault();
        }
    }
}
