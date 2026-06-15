using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("HealthProfiles")]
    public class HealthProfile
    {
        [Key]
        public int ProfileId { get; set; }

        [Required]
        public int PatientId { get; set; }

        [ForeignKey("PatientId")]
        public virtual Patient Patient { get; set; } = null!;

        [StringLength(5)]
        public string? BloodType { get; set; }

        public decimal? Height { get; set; }

        public decimal? Weight { get; set; }

        public DateTime LastUpdated { get; set; } = DateTime.Now;
    }
}