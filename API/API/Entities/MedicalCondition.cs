using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("MedicalConditions")]
    public class MedicalCondition
    {
        [Key]
        public int ConditionId { get; set; }

        [Required]
        [StringLength(150)]
        public string ConditionName { get; set; } = null!;

        public string? Description { get; set; }
        //testing 

        public virtual ICollection<PatientCondition> PatientConditions { get; set; } = new List<PatientCondition>();
    }
}