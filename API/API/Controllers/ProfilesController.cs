using CongNghePhanMem_API.DTOs;
using CongNghePhanMem_API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ProfilesController : ControllerBase
    {
        private readonly IProfileService _profileService;

        public ProfilesController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            return userIdClaim != null ? int.Parse(userIdClaim.Value) : 0;
        }

        [HttpGet("my-profile")]
        public async Task<IActionResult> GetMyProfile()
        {
            var profile = await _profileService.GetMyProfileAsync(GetUserId());
            if (profile == null) return NotFound("Không tìm thấy hồ sơ bệnh nhân.");
            return Ok(profile);
        }

        [HttpPut("my-profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
        {
            var success = await _profileService.UpdateProfileAsync(GetUserId(), dto);
            if (!success) return BadRequest("Cập nhật thất bại.");
            return Ok(new { Message = "Cập nhật thông tin thành công." });
        }

        [HttpGet("conditions")]
        public async Task<IActionResult> GetConditions()
        {
            var conditions = await _profileService.GetConditionsAsync(GetUserId());
            return Ok(conditions);
        }

        [HttpGet("conditions/search")]
        public async Task<IActionResult> SearchConditions([FromQuery] string keyword)
        {
            var results = await _profileService.SearchConditionsAsync(keyword);
            return Ok(results);
        }

        [HttpPost("conditions")]
        public async Task<IActionResult> AddCondition([FromBody] AddConditionDto dto)
        {
            var success = await _profileService.AddConditionAsync(GetUserId(), dto);
            if (!success) return BadRequest("Thêm bệnh lý nền thất bại.");
            return Ok(new { Message = "Thêm bệnh lý nền thành công." });
        }

        [HttpDelete("conditions/{id}")]
        public async Task<IActionResult> RemoveCondition(int id)
        {
            var success = await _profileService.RemoveConditionAsync(GetUserId(), id);
            if (!success) return NotFound("Không tìm thấy bệnh lý nền để xóa hoặc không có quyền.");
            return Ok(new { Message = "Xóa bệnh lý nền thành công." });
        }

        [HttpGet("allergies")]
        public async Task<IActionResult> GetAllergies()
        {
            var allergies = await _profileService.GetAllergiesAsync(GetUserId());
            return Ok(allergies);
        }

        [HttpPost("allergies")]
        public async Task<IActionResult> AddAllergy([FromBody] AddAllergyDto dto)
        {
            var success = await _profileService.AddAllergyAsync(GetUserId(), dto);
            if (!success) return BadRequest("Thêm dị ứng thất bại (có thể đã tồn tại trong danh sách).");
            return Ok(new { Message = "Thêm tiền sử dị ứng thành công." });
        }

        [HttpDelete("allergies/{id}")]
        public async Task<IActionResult> RemoveAllergy(int id)
        {
            var success = await _profileService.RemoveAllergyAsync(GetUserId(), id);
            if (!success) return NotFound("Không tìm thấy dị ứng để xóa hoặc không có quyền.");
            return Ok(new { Message = "Xóa dị ứng thành công." });
        }

        [HttpGet("allergies/search")]
        public async Task<IActionResult> SearchAllergies([FromQuery] string keyword)
        {
            var results = await _profileService.SearchMyAllergiesAsync(GetUserId(), keyword);
            return Ok(results);
        }
    }
}