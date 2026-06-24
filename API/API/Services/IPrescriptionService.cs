using CongNghePhanMem_API.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public interface IPrescriptionService
    {
        Task<IEnumerable<PrescriptionResponseDto>> GetPrescriptionsAsync(int userId, string? status);
        Task<PrescriptionDetailResponseDto?> GetPrescriptionByIdAsync(int userId, int prescriptionId);
        Task<int> CreatePrescriptionAsync(int userId, CreatePrescriptionDto dto);
        Task<PrescriptionActionResponse> AddDrugToPrescriptionAsync(int userId, int prescriptionId, AddDrugDto dto);
        Task<bool> DeletePrescriptionAsync(int userId, int prescriptionId);
    }
}