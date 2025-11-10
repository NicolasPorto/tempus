using Application.Services.Interfaces;
using Domain.Entities;
using Domain.Messaging;
using Domain.Repositories.Interfaces;

namespace Application.Services
{
    public class SessionFocusServices(ISessionFocusRepository sessionFocusRepository) : ISessionFocusService
    {
        public void InitiateFocus(InitiateFocusRequest focusRequest)
        {
            var sessionFocus = 
                new SessionFocus(focusRequest.StartTime, focusRequest.StudyingMinutes, focusRequest.BreakMinutes);

            sessionFocusRepository.Insert(sessionFocus);
        }
    }
}
