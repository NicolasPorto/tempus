using Domain.Messaging;
using Domain.Base;

namespace Application.Services.Interfaces
{
    public interface ISessionFocusService : IServiceBase
    {
        public void InitiateFocus(InitiateFocusRequest focusRequest);
    }
}
