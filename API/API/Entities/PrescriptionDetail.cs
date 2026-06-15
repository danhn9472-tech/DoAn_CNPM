using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("PrescriptionDetails")]
    public class PrescriptionDetail
    {
        [Key]
        public int PrescriptionDetailId { get; set; }

        [Required]
        public int PrescriptionId { get; set; }

        [ForeignKey("PrescriptionId")]
        public virtual Prescription Prescription { get; set; } = null!;

        [Required]
        public int DrugId { get; set; }

        [ForeignKey("DrugId")]
        public virtual Drug Drug { get; set; } = null!;

        public string? Dosage { get; set; }
        public string? Frequency { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}