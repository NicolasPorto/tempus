using Domain.Base;
using Domain.Exceptions;

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

        public SessionFocus() {}

        public SessionFocus(DateTime startTime, int studyingMinutes, int? breakMinutes)
        {
            UUID = Guid.NewGuid();
            StartDtTime = startTime;
            StudyingMinutes = studyingMinutes;

            if (studyingMinutes <= 10)
                throw new TempusException("Studying minutes must be bigger than 10 minutes for consistent learning.");

            if (breakMinutes <= 5 && breakMinutes != null)
                throw new TempusException("Break minutes must be bigger than 5 minutes for consistent learning.");

            BreakMinutes = breakMinutes;
            SupposedFinish = StartDtTime.AddMinutes(studyingMinutes);
        }
    }
}
