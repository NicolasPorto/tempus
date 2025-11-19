using Domain.Base;
using Domain.Exceptions;
using Domain.Messaging;

namespace Domain.Entities
{
    public class SessionFocus : EntityBase
    {
        public DateTime StartDtTime { get; set; }
        public DateTime? FinishDtTime { get; set; }
        public DateTime SupposedFinish { get; set; }
        public int StudyingMinutes { get; set; }
        public int? BreakMinutes { get; set; }
        public int? DistractedMinutes { get; set; }
        public override Guid UUID { get; set; }
        public string Auth0Identifier { get; set; }
        public Guid CategoryUUID { get; set; }

        public SessionFocus() {}

        public SessionFocus(InitiateFocusRequest focusRequest)
        {
            UUID = Guid.NewGuid();
            StartDtTime = focusRequest.StartTime;
            StudyingMinutes = focusRequest.StudyingMinutes;

            if (StudyingMinutes <= 10)
                throw new TempusException("Studying minutes must be bigger than 10 minutes for consistent learning.");

            if (focusRequest.BreakMinutes != null && focusRequest.BreakMinutes <= 5)
                throw new TempusException("Break minutes must be bigger than 5 minutes for consistent learning.");

            BreakMinutes = focusRequest.BreakMinutes;
            SupposedFinish = StartDtTime.AddMinutes(StudyingMinutes);
            Auth0Identifier = focusRequest.Auth0UserId;
            CategoryUUID = focusRequest.CategoryUUID;

        }
    }
}
