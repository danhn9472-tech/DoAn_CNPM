using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("DrugInteractions")]
    public class DrugInteraction
    {
        [Key]
        public int InteractionId { get; set; }

        [Required]
        public int DrugId1 { get; set; }

        [ForeignKey("DrugId1")]
        public virtual Drug Drug1 { get; set; } = null!;

        [Required]
        public int DrugId2 { get; set; }

        [ForeignKey("DrugId2")]
        public virtual Drug Drug2 { get; set; } = null!;

        [Required]
        public InteractionSeverity SeverityLevel { get; set; }

        public string? InteractionEffect { get; set; }

        public string? Recommendation { get; set; }
    }
}