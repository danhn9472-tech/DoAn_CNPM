using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("Patients")]
    public class Patient
    {
        [Key]
        public int PatientId { get; set; }

        [Required]
        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;

        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = null!;

        public DateOnly? DateOfBirth { get; set; }

        [StringLength(10)]
        public string? Gender { get; set; }

        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }

        public virtual HealthProfile? HealthProfile { get; set; }
        public virtual ICollection<PatientCondition> PatientConditions { get; set; } = new List<PatientCondition>();
        public virtual ICollection<PatientAllergy> PatientAllergies { get; set; } = new List<PatientAllergy>();
        public virtual ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();
    }
}