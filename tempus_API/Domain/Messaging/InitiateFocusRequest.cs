namespace Domain.Messaging
{
    public class InitiateFocusRequest
    {
        public DateTime StartTime { get; set; }
        public int StudyingMinutes { get; set; }
        public int? BreakMinutes { get; set; }
    }
}
