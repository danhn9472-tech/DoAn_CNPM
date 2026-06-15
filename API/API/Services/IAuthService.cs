using CongNghePhanMem_API.DTOs; // Cập nhật namespace
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public interface IAuthService
    {
        Task<AuthResponse> LoginAsync(LoginRequest request);
        Task<AuthResponse> RegisterAsync(RegisterRequest request);
        Task<UserProfileResponse?> GetProfileAsync(int userId);
    }
}