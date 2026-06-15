using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("Prescriptions")]
    public class Prescription
    {
        [Key]
        public int PrescriptionId { get; set; }

        [Required]
        public int PatientId { get; set; }

        [ForeignKey("PatientId")]
        public virtual Patient Patient { get; set; } = null!;

        public int? DoctorId { get; set; }

        [ForeignKey("DoctorId")]
        public virtual Doctor? Doctor { get; set; }

        public string? Diagnosis { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.Now;

        [Required]
        public PrescriptionStatus Status { get; set; }
        public string? Notes { get; set; }

        public virtual ICollection<PrescriptionDetail> PrescriptionDetails { get; set; } = new List<PrescriptionDetail>();
    }
}