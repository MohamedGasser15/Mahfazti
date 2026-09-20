namespace Mahfazti.Core.DTOs.Category
{
    public class BulkDeleteResultDto
    {
        public int TotalRequested { get; set; }
        public int DeletedCount { get; set; }
        public int ArchivedCount { get; set; }
        public List<int> ProcessedIds { get; set; } = new();
        public string Message { get; set; } = string.Empty;
    }
}
