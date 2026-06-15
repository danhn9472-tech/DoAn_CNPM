using CongNghePhanMem_API.DTOs;
using CongNghePhanMem_API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace CongNghePhanMem_API.Controllers
{
    [Authorize(Roles = "Admin")] // Chỉ Admin mới có quyền truy cập các API trong Controller này
    [Route("api/admin")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        private readonly IDrugService _drugService;

        public AdminController(IDrugService drugService)
        {
            _drugService = drugService;
        }

        /// <summary>
        /// Thêm thuốc mới vào danh mục gốc.
        /// </summary>
        [HttpPost("drugs")]
        public async Task<IActionResult> AddDrug([FromBody] DrugBaseDto dto)
        {
            var drugId = await _drugService.AddDrugAsync(dto);
            return CreatedAtAction(nameof(DrugsController.GetById), "Drugs", new { id = drugId }, new { DrugId = drugId, Message = "Thêm thuốc mới thành công." });
        }

        /// <summary>
        /// Cập nhật thông tin thuốc trong danh mục.
        /// </summary>
        [HttpPut("drugs/{id}")]
        public async Task<IActionResult> UpdateDrug(int id, [FromBody] DrugBaseDto dto)
        {
            var success = await _drugService.UpdateDrugAsync(id, dto);
            if (!success) return NotFound("Không tìm thấy thông tin thuốc để cập nhật.");
            
            return Ok(new { Message = "Cập nhật thông tin thuốc thành công." });
        }

        /// <summary>
        /// Lấy danh sách tất cả các quy tắc tương tác thuốc.
        /// </summary>
        [HttpGet("interactions")]
        public async Task<IActionResult> GetAllInteractions()
        {
            var interactions = await _drugService.GetAllDrugInteractionsAsync();
            return Ok(interactions);
        }
        /// <summary>
        /// Cấu hình Quy tắc Tương tác Thuốc.
        /// </summary>
        [HttpPost("interactions")]
        public async Task<IActionResult> AddInteractionRule([FromBody] CreateInteractionRuleDto dto)
        {
            try
            {
                var interactionId = await _drugService.AddDrugInteractionAsync(dto);
                return CreatedAtAction(null, new { InteractionId = interactionId, Message = "Thêm quy tắc tương tác thuốc thành công." });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        /// Cập nhật một quy tắc tương tác thuốc hiện có.
        [HttpPut("interactions/{id}")]
        public async Task<IActionResult> UpdateInteractionRule(int id, [FromBody] CreateInteractionRuleDto dto)
        {
            try
            {
                var success = await _drugService.UpdateDrugInteractionAsync(id, dto);
                if (!success) return NotFound("Không tìm thấy quy tắc tương tác thuốc để cập nhật.");
                return Ok(new { Message = "Cập nhật quy tắc tương tác thuốc thành công." });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        /// Xóa một quy tắc tương tác thuốc khỏi hệ thống.
        [HttpDelete("interactions/{id}")]
        public async Task<IActionResult> DeleteInteractionRule(int id)
        {
            var success = await _drugService.DeleteDrugInteractionAsync(id);
            if (!success) return NotFound("Không tìm thấy quy tắc tương tác thuốc để xóa.");
            return Ok(new { Message = "Xóa quy tắc tương tác thuốc thành công." });
        }
    }
}