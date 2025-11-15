using Application.Services.Interfaces;
using Domain.Entities;
using Domain.Messaging;
using Domain.Repositories.Interfaces;

namespace Application.Services
{
    public class SessionFocusServices(ISessionFocusRepository sessionFocusRepository) : ISessionFocusService
    {
        public void InformUnfocusedTime(Guid sessionUUID, int minutesDistracted)
        {
            var sessionFocus = sessionFocusRepository.Get(sessionUUID);
            sessionFocus.DistractedMinutes += minutesDistracted;

            sessionFocusRepository.Update(sessionFocus);
        }

        public void InitiateFocus(InitiateFocusRequest focusRequest)
        {
            var sessionFocus = 
                new SessionFocus(focusRequest.StartTime, focusRequest.StudyingMinutes, focusRequest.BreakMinutes);

            sessionFocusRepository.Insert(sessionFocus);
        }
    }
}
