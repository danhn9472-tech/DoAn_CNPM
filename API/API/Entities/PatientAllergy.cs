using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("PatientAllergies")]
    public class PatientAllergy
    {
        [Key]
        public int AllergyId { get; set; }

        [Required]
        public int PatientId { get; set; }

        [ForeignKey("PatientId")]
        public virtual Patient Patient { get; set; } = null!;

        [Required]
        public int DrugId { get; set; }

        [ForeignKey("DrugId")]
        public virtual Drug Drug { get; set; } = null!;

        public string? Severity { get; set; }
        public string? Symptoms { get; set; }
        public DateTime? NotedDate { get; set; }
    }
}