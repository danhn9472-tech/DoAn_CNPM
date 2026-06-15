using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("PatientConditions")]
    public class PatientCondition
    {
        [Key]
        public int PatientConditionId { get; set; }

        [Required]
        public int PatientId { get; set; }

        [ForeignKey("PatientId")]
        public virtual Patient Patient { get; set; } = null!;

        [Required]
        public int ConditionId { get; set; }

        [ForeignKey("ConditionId")]
        public virtual MedicalCondition MedicalCondition { get; set; } = null!;

        public DateTime? DiagnosedDate { get; set; }
        public string? Notes { get; set; }
    }
}