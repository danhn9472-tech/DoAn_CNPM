using CongNghePhanMem_API.Entities;
namespace CongNghePhanMem_API.DTOs
{
    public class DrugSearchResponseDto
    {
        public int DrugId { get; set; }
        public string DrugName { get; set; } = null!;
        public string? ActiveIngredient { get; set; }
    }

    public class DrugDetailDto
    {
        public int DrugId { get; set; }
        public string DrugName { get; set; } = null!;
        public string? ActiveIngredient { get; set; }
        public string? Instruction { get; set; }
        public string? SideEffects { get; set; }
    }

    public class DrugBaseDto
    {
        public string DrugName { get; set; } = null!;
        public string? ActiveIngredient { get; set; }
        public string? Instruction { get; set; }
        public string? SideEffects { get; set; }
    }

    public class CreateInteractionRuleDto
    {
        public int DrugId1 { get; set; }
        public int DrugId2 { get; set; }
        public InteractionSeverity SeverityLevel { get; set; }
        public string InteractionEffect { get; set; } = null!;
        public string? Recommendation { get; set; }
    }

    public class DrugInteractionResponseDto
    {
        public int InteractionId { get; set; }
        public int DrugId1 { get; set; }
        public string DrugName1 { get; set; } = null!;
        public int DrugId2 { get; set; }
        public string DrugName2 { get; set; } = null!;
        public string SeverityLevel { get; set; } = null!;
        public string InteractionEffect { get; set; } = null!;
        public string? Recommendation { get; set; }
    }
}