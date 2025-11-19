using Domain.Base.Repositories;
using Domain.Base.Repository;
using Domain.Entities;
using Domain.RawQueries;
using Domain.Repositories.Interfaces;
using MySql.Data.MySqlClient;
using Mysqlx.Crud;
using System.Collections.Generic;

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
                    COALESCE(ROUND(AVG(TIMESTAMPDIFF(MINUTE, StartDtTime, FinishDtTime))), 0) 'TimeStudied',
                    COALESCE(SUM(TIMESTAMPDIFF(MINUTE, StartDtTime, FinishDtTime)), 0) 'TotalTimeStudied',
                    COALESCE(SUM(StudyingMinutes), 0) 'SupposedTotalTimeStudied'
                FROM
                    SessionFocus
                WHERE
                    FinishDtTime IS NOT NULL
                	AND Auth0Identifier = @auth0Identifier
                """;
            var param = new MySqlParameter("@auth0Identifier", auth0Identifier);
            return RawQuery<AverageStudyTimeStatsRawQuery>(sql, param).SingleOrDefault();
        }

        public ObtainFinishedSessions ObtainFinishedSessions(string auth0Identifier)
        {
            const string sql =
                """
                SELECT
                    COUNT(1) 'FinishedSessions'
                FROM
                    SessionFocus
                WHERE
                    FinishDtTime IS NOT NULL
                	AND Auth0Identifier = @auth0Identifier
                """;
            var param = new MySqlParameter("@auth0Identifier", auth0Identifier);
            return RawQuery<ObtainFinishedSessions>(sql, param).SingleOrDefault();
        }

        public ObtainSessionStreak ObtainSessionStreak(string auth0Identifier)
        {
            const string sql =
                """
                SELECT COUNT(*) as CurrentStreak
                FROM SessionFocus
                WHERE Auth0Identifier = @auth0Identifier
                AND StartDtTime > COALESCE(
                (
                    SELECT MAX(StartDtTime)
                    FROM SessionFocus
                    WHERE Auth0Identifier = @auth0Identifier
                    AND (FinishDtTime<SupposedFinish OR FinishDtTime IS NULL)
                    ),
                    (SELECT sf2.StartDtTime FROM SessionFocus sf2 WHERE Auth0Identifier = @auth0Identifier ORDER BY sf2.StartDtTime ASC)
                );
                """;
            var param = new MySqlParameter("@auth0Identifier", auth0Identifier);
            return RawQuery<ObtainSessionStreak>(sql, param).SingleOrDefault();
        }
    }
}
