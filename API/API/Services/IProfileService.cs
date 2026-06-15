using CongNghePhanMem_API.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public interface IProfileService
    {
        Task<HealthProfileResponseDto?> GetMyProfileAsync(int userId);
        Task<bool> UpdateProfileAsync(int userId, UpdateProfileDto dto);
        Task<IEnumerable<PatientConditionResponseDto>> GetConditionsAsync(int userId);
        Task<bool> AddConditionAsync(int userId, AddConditionDto dto);
        Task<bool> RemoveConditionAsync(int userId, int patientConditionId);
        Task<IEnumerable<PatientAllergyResponseDto>> GetAllergiesAsync(int userId);
        Task<bool> AddAllergyAsync(int userId, AddAllergyDto dto);
    }
}