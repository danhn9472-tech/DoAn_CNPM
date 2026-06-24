using Microsoft.AspNetCore.Mvc;
using CongNghePhanMem_API.DTOs; // Cập nhật namespace cho DTOs
using CongNghePhanMem_API.Services; // Thêm namespace cho Services
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace CongNghePhanMem_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var response = await _authService.LoginAsync(request);

            if (!response.Success)
            {
                // Trả về 401 Unauthorized nếu đăng nhập thất bại hoặc 400 BadRequest nếu tài khoản bị khóa
                if (response.Message == "Tài khoản đang bị khóa.")
                {
                    return BadRequest(response);
                }
                return Unauthorized(response);
            }
            return Ok(response);
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var response = await _authService.RegisterAsync(request);
            if (!response.Success)
            {
                return BadRequest(response);
            }
            return Ok(response);
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            // Lấy UserId từ Claim NameIdentifier đã lưu trong Token lúc Login
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null) return Unauthorized();

            int userId = int.Parse(userIdClaim.Value);
            var profile = await _authService.GetProfileAsync(userId);

            if (profile == null) return NotFound("Không tìm thấy thông tin người dùng.");

            return Ok(profile);
        }
    }
}