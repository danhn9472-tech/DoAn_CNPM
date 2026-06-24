using CongNghePhanMem_API.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public interface IDrugService
    {
        Task<IEnumerable<DrugSearchResponseDto>> SearchDrugsAsync(string keyword);
        Task<DrugDetailDto?> GetDrugByIdAsync(int id);
        Task<int> AddDrugAsync(DrugBaseDto dto);
        Task<bool> UpdateDrugAsync(int id, DrugBaseDto dto);
        Task<IEnumerable<DrugInteractionResponseDto>> GetAllDrugInteractionsAsync();
        Task<int> AddDrugInteractionAsync(CreateInteractionRuleDto dto);
        Task<bool> UpdateDrugInteractionAsync(int id, CreateInteractionRuleDto dto);
        Task<bool> DeleteDrugInteractionAsync(int id);
    }
}