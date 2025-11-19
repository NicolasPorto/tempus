using Domain.Base;
using Domain.Messaging;
using Domain.RawQueries;

namespace Application.Services.Interfaces
{
    public interface ISessionFocusService : IServiceBase
    {
        Guid InitiateFocus(InitiateFocusRequest focusRequest);
        void InformUnfocusedTime(Guid sessionUUID, int minutesOnfocused);
        void StopFocus(Guid sessionUUID, DateTime dtFinishTime);
        AverageStudyTimeStatsRawQuery ObtainAverageStudiedMinutes(string auth0Identifier);
        ObtainFinishedSessions ObtainFinishedSessions(string auth0Identifier);
        ObtainSessionStreak ObtainSessionStreak(string auth0Identifier);
    }
}
