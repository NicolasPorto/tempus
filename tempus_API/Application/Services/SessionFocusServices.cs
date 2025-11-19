using Application.Services.Interfaces;
using Domain.Entities;
using Domain.Messaging;
using Domain.RawQueries;
using Domain.Repositories.Interfaces;

namespace Application.Services
{
    public class SessionFocusServices(ISessionFocusRepository sessionFocusRepository) : ISessionFocusService
    {
        public void InformUnfocusedTime(Guid sessionUUID, int minutesDistracted)
        {
            var sessionFocus = (SessionFocus)sessionFocusRepository.Get(sessionUUID);
            sessionFocus.DistractedMinutes += minutesDistracted;

            sessionFocusRepository.Update(sessionFocus);
        }

        public Guid InitiateFocus(InitiateFocusRequest focusRequest)
        {
            var sessionFocus = 
                new SessionFocus(focusRequest);

            sessionFocusRepository.Insert(sessionFocus);

            return sessionFocus.UUID;
        }

        public AverageStudyTimeStatsRawQuery ObtainAverageStudiedMinutes(string auth0Identifier) 
            => sessionFocusRepository.ObtainAverageStudiedMinutes(auth0Identifier);

        public void StopFocus(Guid sessionUUID)
        {
            var sessionFocus = (SessionFocus)sessionFocusRepository.Get(sessionUUID);
            sessionFocus.FinishDtTime = DateTime.UtcNow;
            sessionFocusRepository.Update(sessionFocus);
        }
    }
}
