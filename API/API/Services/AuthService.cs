using CongNghePhanMem_API.Data;
using CongNghePhanMem_API.Entities;
using CongNghePhanMem_API.DTOs; // Thêm namespace cho DTOs
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public AuthService(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            // 1. Tìm người dùng trong database
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == request.Username);

            // 2. Kiểm tra user và password
            // Lưu ý: Trong thực tế nên dùng BCrypt để hash password thay vì so sánh trực tiếp
            if (user == null || user.PasswordHash != request.Password)
            {
                return new AuthResponse
                {
                    Success = false,
                    Message = "Tên đăng nhập hoặc mật khẩu không đúng."
                };
            }

            if (!user.IsActive)
            {
                return new AuthResponse { Success = false, Message = "Tài khoản đang bị khóa." };
            }

            // 3. Tạo Token
            var token = GenerateJwtToken(user);

            return new AuthResponse
            {
                Success = true,
                Message = "Đăng nhập thành công.",
                Token = token,
                Username = user.Username,
                Role = user.Role.ToString()
            };
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            // 1. Kiểm tra xem username đã tồn tại chưa
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
            {
                return new AuthResponse { Success = false, Message = "Tên đăng nhập đã tồn tại." };
            }

            // 2. Tạo đối tượng User mới
            var user = new User
            {
                Username = request.Username,
                PasswordHash = request.Password, // Lưu ý: Trong thực tế hãy sử dụng BCrypt để hash mật khẩu
                Role = request.Role,
                IsActive = true,
                CreatedAt = DateTime.Now
            };

            // 3. Tự động tạo bản ghi Patient hoặc Doctor tương ứng dựa trên Role
            if (request.Role == UserRole.Patient)
            {
                user.Patient = new Patient { FullName = request.FullName };
            }
            else if (request.Role == UserRole.Doctor)
            {
                user.Doctor = new Doctor { FullName = request.FullName };
            }

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return new AuthResponse
            {
                Success = true,
                Message = "Đăng ký tài khoản thành công.",
                Username = user.Username,
                Role = user.Role.ToString()
            };
        }

        public async Task<UserProfileResponse?> GetProfileAsync(int userId)
        {
            var user = await _context.Users
                .Include(u => u.Patient)
                .Include(u => u.Doctor)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null) return null;

            var response = new UserProfileResponse
            {
                Username = user.Username,
                Role = user.Role.ToString(),
                FullName = "N/A" // Mặc định nếu không tìm thấy thông tin chi tiết
            };

            if (user.Role == UserRole.Patient && user.Patient != null)
            {
                response.FullName = user.Patient.FullName;
            }
            else if (user.Role == UserRole.Doctor && user.Doctor != null)
            {
                response.FullName = user.Doctor.FullName;
            }

            return response;
        }

        private string GenerateJwtToken(User user)
        {
            var jwtSettings = _configuration.GetSection("Jwt");
            var jwtKey = jwtSettings["Key"] ?? throw new InvalidOperationException("JWT Key chưa được cấu hình.");
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role.ToString())
            };

            var token = new JwtSecurityToken(
                issuer: jwtSettings["Issuer"],
                audience: jwtSettings["Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(Convert.ToDouble(jwtSettings["DurationInMinutes"])),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}