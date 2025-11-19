using Domain.Base;
using Domain.Messaging;
using Domain.RawQueries;

namespace Application.Services.Interfaces
{
    public interface ISessionFocusService : IServiceBase
    {
        Guid InitiateFocus(InitiateFocusRequest focusRequest);
        void InformUnfocusedTime(Guid sessionUUID, int minutesOnfocused);
        void StopFocus(Guid sessionUUID);
        public AverageStudyTimeStatsRawQuery ObtainAverageStudiedMinutes(string auth0Identifier);
    }
}
