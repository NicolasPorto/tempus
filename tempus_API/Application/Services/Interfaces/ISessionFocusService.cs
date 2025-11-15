using Domain.Messaging;
using Domain.Base;

namespace Application.Services.Interfaces
{
    public interface ISessionFocusService : IServiceBase
    {
        void InitiateFocus(InitiateFocusRequest focusRequest);
        void InformUnfocusedTime(Guid sessionUUID, int minutesOnfocused);
        void StopFocus(Guid sessionUUID);
    }
}
