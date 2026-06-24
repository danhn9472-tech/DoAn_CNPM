using CongNghePhanMem_API.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public interface IDoctorService
    {
        Task<IEnumerable<DoctorSearchResponseDto>> SearchDoctorsAsync(string keyword);
    }
}
