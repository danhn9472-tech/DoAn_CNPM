using CongNghePhanMem_API.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public interface IDrugService
    {
        Task<IEnumerable<DrugSearchResponseDto>> SearchDrugsAsync(string keyword);
        Task<DrugDetailDto?> GetDrugByIdAsync(int id);
    }
}