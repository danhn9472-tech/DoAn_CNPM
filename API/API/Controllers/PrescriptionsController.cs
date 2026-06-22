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
    public class PrescriptionsController : ControllerBase
    {
        private readonly IPrescriptionService _prescriptionService;

        public PrescriptionsController(IPrescriptionService prescriptionService)
        {
            _prescriptionService = prescriptionService;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            return userIdClaim != null ? int.Parse(userIdClaim.Value) : 0;
        }

        [HttpGet]
        public async Task<IActionResult> GetPrescriptions([FromQuery] string? status)
        {
            var result = await _prescriptionService.GetPrescriptionsAsync(GetUserId(), status);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPrescriptionDetail(int id)
        {
            var result = await _prescriptionService.GetPrescriptionByIdAsync(GetUserId(), id);
            if (result == null) return NotFound("Không tìm thấy đơn thuốc.");
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> CreatePrescription([FromBody] CreatePrescriptionDto dto)
        {
            var id = await _prescriptionService.CreatePrescriptionAsync(GetUserId(), dto);
            return Ok(new { PrescriptionId = id, Message = "Tạo đơn thuốc nháp thành công." });
        }

        [HttpPost("{id}/items")]
        public async Task<IActionResult> AddDrug(int id, [FromBody] AddDrugDto dto)
        {
            var result = await _prescriptionService.AddDrugToPrescriptionAsync(GetUserId(), id, dto);
            
            if (!result.Success) return Conflict(result); // Trả về 409 Conflict kèm JSON lỗi

            return StatusCode(201, result); // Trả về 201 Created nếu thành công
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> RemovePrescription(int id)
        {
            var success = await _prescriptionService.DeletePrescriptionAsync(GetUserId(), id);
            if (!success) return NotFound(new { Message = "Không tìm thấy đơn thuốc hoặc bạn không có quyền xóa." });
            return Ok(new { Message = "Đã xóa đơn thuốc thành công." });
        }
    }
}