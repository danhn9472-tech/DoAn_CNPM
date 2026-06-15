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
}