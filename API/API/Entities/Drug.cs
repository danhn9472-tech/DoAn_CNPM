using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CongNghePhanMem_API.Entities
{
    [Table("Drugs")]
    public class Drug
    {
        [Key]
        public int DrugId { get; set; }

        [Required]
        [StringLength(150)]
        public string DrugName { get; set; } = null!;

        [StringLength(150)]
        public string? ActiveIngredient { get; set; }

        public string? Instruction { get; set; }
        public string? SideEffects { get; set; }

        // Self-referencing relationship for interactions
        [InverseProperty("Drug1")]
        public virtual ICollection<DrugInteraction> InteractionsAsPrimary { get; set; } = new List<DrugInteraction>();

        [InverseProperty("Drug2")]
        public virtual ICollection<DrugInteraction> InteractionsAsSecondary { get; set; } = new List<DrugInteraction>();

        public virtual ICollection<PatientAllergy> PatientAllergies { get; set; } = new List<PatientAllergy>();

        public virtual ICollection<PrescriptionDetail> PrescriptionDetails { get; set; } = new List<PrescriptionDetail>();
    }
}